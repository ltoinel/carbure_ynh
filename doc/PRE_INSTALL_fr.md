- Carbure a besoin d'un **domaine dédié** (par exemple `budget.exemple.org`) : il ne
  s'installe pas dans un sous-chemin.
- Laissez l'application **publique** (visiteurs) : les applications mobiles et la
  synchronisation quotidienne appellent son API en dehors du portail YunoHost. Carbure
  demande toujours sa propre connexion : ses comptes ne sont pas ceux de YunoHost (pas de
  SSO).
- L'utilisateur YunoHost choisi à l'installation devient l'administrateur de Carbure, avec
  le mot de passe saisi ici (8 caractères minimum).
- L'installation construit [woob](https://woob.tech/), qui synchronise les banques, dans un
  environnement virtuel : comptez quelques minutes et environ 500 Mo.
