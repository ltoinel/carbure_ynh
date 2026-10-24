#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# Version of woob installed in its virtualenv: the WOOB_VERSION of docker/Dockerfile of
# Carbure, the one its bank modules are tested with
woob_version="3.7"

# Python packages of the bank modules, that woob checks but never installs (it refuses to
# load a module missing one): as docker/Dockerfile of Carbure. curl_cffi (BNP),
# python-jose and chompjs (BPCE group), schwifty (Societe Generale), pycryptodomex
# (employee savings). Changing the list rebuilds the virtualenv
woob_packages="curl_cffi>=0.7 python-jose chompjs schwifty pycryptodomex"

# woob command written in the configuration of Carbure: its banks (and their credentials)
# are kept in the data directory
woob_command() {
    echo "env HOME=$data_dir/woob $install_dir/woob/bin/woob"
}

# Layout of the install directory: data/ is the data directory (configuration, logs,
# cache, woob), as /data in the Docker image of Carbure
_carbure_layout() {
    ynh_app_upstream_version > "$install_dir/VERSION"
    ln -sfn "$data_dir" "$install_dir/data"
    mkdir -p "$data_dir"/{conf,logs,cache,woob}

    chown -R "$app:www-data" "$install_dir"
    # The sources are read by nginx (portal, Swagger UI) and PHP-FPM, never written
    chmod -R u=rwX,g=rX,o= "$install_dir"
    chown -R "$app:$app" "$data_dir"
    # Bank credentials (woob) and secrets (conf): only the user of Carbure
    chmod -R u=rwX,go= "$data_dir"
}

# woob in its own virtualenv, (re)built only when it is missing or when the version of woob,
# its packages or the version of Python changed: building it takes several minutes
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

# Bank modules of woob, once an administrator has trusted the repository from the
# Accounts page of the portal (as the Docker image does at each start); a failure is
# only a warning: the modules are updated again from the portal
_woob_update() {
    if [ -z "$(ls -A "$data_dir/woob/.local/share/woob/keyrings" 2>/dev/null)" ]; then
        return 0
    fi
    ynh_exec_as_app env HOME="$data_dir/woob" "$install_dir/woob/bin/woob" config update < /dev/null \
        || ynh_print_warn "The bank modules of woob could not be updated: update them from the Accounts page of Carbure"
}

# The daily bank synchronization (cron), at a time of its own for each instance
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

# PHP settings of Carbure (docker/php.ini), kept when an admin changed them
_php_settings() {
    ynh_app_setting_set_default --key=php_memory_limit --value=256M
    ynh_app_setting_set_default --key=php_upload_max_filesize --value=32M
}
