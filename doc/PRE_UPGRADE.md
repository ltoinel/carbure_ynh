YunoHost makes a backup of Carbure before the upgrade and restores it if the upgrade fails.

- The upgrade applies the migrations of the database: the old version of Carbure can no longer open it afterwards.
- Read the [release notes](https://github.com/ltoinel/Carbure/releases) of the new version of Carbure, especially before a major version.
- The synchronization of the banks is unavailable during the upgrade; when the version of woob changes, rebuilding it takes a few minutes.
