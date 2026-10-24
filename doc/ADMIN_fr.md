### Où sont les fichiers ?

| Quoi | Où |
|---|---|
| Configuration (`prod.ini`, avec ses secrets) | `__DATA_DIR__/conf/` |
| Logs de Carbure | `__DATA_DIR__/logs/` (90 jours par défaut) |
| woob : modules bancaires et identifiants de vos banques | `__DATA_DIR__/woob/` |
| Sources et environnement virtuel de woob | `__INSTALL_DIR__/` |

La plupart des réglages se modifient dans le portail, **Administration → Paramètres** : inutile d'éditer `prod.ini`. Les sauvegardes YunoHost comprennent le dossier de données et la base (sauf les sauvegardes `--core-only` : sauvegardez alors `__DATA_DIR__` vous-même).

### Synchronisation

`/etc/cron.d/__APP__` synchronise tous les comptes une fois par jour, à __SYNC_HOUR__ h __SYNC_MINUTE__, par `__INSTALL_DIR__/ynh-sync.sh`. Une banque qui demande une validation sur le téléphone (authentification forte) se synchronise depuis le portail.

En cas d'échec de la synchronisation, mettez à jour les modules bancaires depuis la page **Comptes** ; les mises à jour du paquet les mettent aussi à jour.

### Mises à jour

Une mise à jour applique les migrations de la base de données (`tools/migrate.php`), met à jour les modules bancaires, et reconstruit woob quand sa version change. YunoHost sauvegarde Carbure avant. Lisez les [notes de version](https://github.com/ltoinel/Carbure/releases) de Carbure avant une mise à jour majeure.

Plus d'informations : [documentation de Carbure](https://carbure.org/).
