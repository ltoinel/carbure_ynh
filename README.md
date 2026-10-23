# Carbure pour YunoHost

[Carbure](https://carbure.org) empaqueté pour [YunoHost](https://yunohost.org) : un
gestionnaire de budget du foyer auto-hébergé, avec synchronisation bancaire automatique
([woob](https://woob.tech/)), catégories, budgets, tendances, et applications
[iPhone](https://apps.apple.com/fr/app/carbure/id6824057363) et
[Android](https://play.google.com/store/apps/details?id=org.carbure.app).

*[Read in English](README_en.md)*

![Transactions du mois](doc/screenshots/transactions.png)

## Installer

```bash
sudo yunohost app install https://github.com/ltoinel/carbure_ynh
```

Carbure a besoin d'un domaine dédié. Lisez d'abord [doc/PRE_INSTALL_fr.md](doc/PRE_INSTALL_fr.md) ;
l'administration est décrite dans [doc/ADMIN_fr.md](doc/ADMIN_fr.md).

## Ce que fait le paquet

- Carbure dans `/var/www/<app>`, servi par nginx et PHP-FPM (PHP 8.4, MariaDB).
- Ses données (configuration, logs, woob avec les banques) dans `/home/yunohost.app/<app>`.
- Installé sans l'assistant web par `tools/install.php` de Carbure : schéma, catégories,
  règles et insights de départ, l'utilisateur YunoHost choisi comme administrateur.
- woob dans un environnement virtuel, reconstruit à chaque mise à jour ; migrations
  appliquées à chaque mise à jour.
- Synchronisation quotidienne de tous les comptes (cron).

## État

En cours, pas encore au catalogue YunoHost. Il installe Carbure 1.10.0 (la première
version avec `tools/install.php`). Testé avec
[package_check](https://github.com/YunoHost/package_check) : pas encore ; vos retours sont
les bienvenus dans les [issues](https://github.com/ltoinel/carbure_ynh/issues).

## Liens

- Carbure : <https://github.com/ltoinel/Carbure> · documentation <https://carbure.org>
- Signaler un bug du paquet : <https://github.com/ltoinel/carbure_ynh/issues>
