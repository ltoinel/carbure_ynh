#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# woob version tested by Carbure (WOOB_VERSION of its docker/Dockerfile)
woob_version="3.7"

# Python packages required by some bank modules, that woob does not install itself
woob_packages="curl_cffi>=0.7 python-jose chompjs schwifty pycryptodomex"

# woob command of Carbure: woob keeps its banks in the data directory
woob_command() {
    echo "env HOME=$data_dir/woob $install_dir/woob/bin/woob"
}

# Carbure reads its data in <install_dir>/data: link it to the data directory
_carbure_layout() {
    ynh_app_upstream_version > "$install_dir/VERSION"
    ln -sfn "$data_dir" "$install_dir/data"
    mkdir -p "$data_dir"/{conf,logs,cache,woob}

    chown -R "$app:www-data" "$install_dir"
    # Sources: read-only for nginx and PHP-FPM
    chmod -R u=rwX,g=rX,o= "$install_dir"
    chown -R "$app:$app" "$data_dir"
    # Bank credentials and secrets: only the app user
    chmod -R u=rwX,go= "$data_dir"
}

# Build the woob virtualenv, only when woob, its packages or Python changed (slow)
_woob_install() {
    local wanted
    wanted="$woob_version $woob_packages python$(python3 -c 'import sys; print("%d.%d" % sys.version_info[:2])')"
    if [ -x "$install_dir/woob/bin/woob" ] && [ "$(ynh_app_setting_get --key=woob_built)" = "$wanted" ]; then
        ynh_print_info "woob $woob_version is already installed"
        return 0
    fi

    ynh_print_info "Installing woob $woob_version (bank synchronization), this takes a few minutes..."
    ynh_safe_rm "$install_dir/woob"
    ynh_exec_as_app python3 -m venv "$install_dir/woob"
    ynh_exec_as_app "$install_dir/woob/bin/pip" install --quiet --no-cache-dir --upgrade "pip>=26.1.2" "setuptools>=78.1.1"
    # shellcheck disable=SC2086
    ynh_exec_as_app "$install_dir/woob/bin/pip" install --quiet --no-cache-dir "woob==$woob_version" $woob_packages
    ynh_exec_as_app "$install_dir/woob/bin/python" -c "import curl_cffi, lxml.etree, woob, jose, chompjs, schwifty, Cryptodome"
    ynh_app_setting_set --key=woob_built --value="$wanted"
}

# Update the bank modules of woob. Without a trusted keyring yet, Carbure trusts the
# official one if it matches the keyring it pins (tools/woob-trust.php). Never fatal.
_woob_update() {
    if [ -z "$(ls -A "$data_dir/woob/.local/share/woob/keyrings" 2>/dev/null)" ]; then
        ynh_exec_as_app "php$php_version" "$install_dir/tools/woob-trust.php" < /dev/null > /dev/null 2>&1 \
            || ynh_print_warn "The woob repository is not trusted yet: confirm its fingerprint from the Accounts page of Carbure (update the bank modules)"
        return 0
    fi
    ynh_exec_as_app env HOME="$data_dir/woob" "$install_dir/woob/bin/woob" config update < /dev/null \
        || ynh_print_warn "The bank modules of woob could not be updated: update them from the Accounts page of Carbure"
}

# Daily bank synchronization (cron), at a random time kept in the settings
_sync_add() {
    sync_hour=$(ynh_app_setting_get --key=sync_hour)
    sync_minute=$(ynh_app_setting_get --key=sync_minute)
    if [ -z "$sync_hour" ]; then
        sync_hour=$((RANDOM % 3 + 3))
        sync_minute=$(printf "%02d" $((RANDOM % 60)))
        ynh_app_setting_set --key=sync_hour --value="$sync_hour"
        ynh_app_setting_set --key=sync_minute --value="$sync_minute"
    fi
    ynh_config_add --template="sync.sh" --destination="$install_dir/ynh-sync.sh"
    chown "$app:$app" "$install_dir/ynh-sync.sh"
    chmod 750 "$install_dir/ynh-sync.sh"
    ynh_config_add --template="cron" --destination="/etc/cron.d/$app"
}

# http-level nginx settings (login rate limit zone), needed by the domain configuration
_nginx_http_add() {
    ynh_config_add --template="nginx-http.conf" --destination="/etc/nginx/conf.d/$app-http.conf"
}

# PHP settings of Carbure, kept if an admin changed them
_php_settings() {
    ynh_app_setting_set_default --key=php_memory_limit --value=256M
    ynh_app_setting_set_default --key=php_upload_max_filesize --value=32M
}
