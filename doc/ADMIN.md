### Where are the files?

| What | Where |
|---|---|
| Configuration (`prod.ini`, with its secrets) | `__DATA_DIR__/conf/` |
| Logs of Carbure | `__DATA_DIR__/logs/` (kept 90 days by default) |
| woob: bank modules and the credentials of your banks | `__DATA_DIR__/woob/` |
| Sources and the virtualenv of woob | `__INSTALL_DIR__/` |

Most settings are changed in the portal, **Administration → Settings**: no need to edit
`prod.ini`. The YunoHost backups include the data directory and the database (not the
backups made with `--core-only`: back up `__DATA_DIR__` yourself then).

### Synchronization

`/etc/cron.d/__APP__` synchronizes every account once a day, at
__SYNC_HOUR__:__SYNC_MINUTE__, through `__INSTALL_DIR__/ynh-sync.sh`. A bank asking for a
validation on the phone (strong authentication) is synchronized from the portal.

When the synchronization fails, update the bank modules from the **Accounts** page; the
upgrades of the package update them too.

### Upgrades

An upgrade applies the migrations of the database (`tools/migrate.php`) and rebuilds woob.
Read the [release notes](https://github.com/ltoinel/Carbure/releases) of Carbure before a
major upgrade.

More: [documentation of Carbure](https://carbure.org/).
