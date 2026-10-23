- Carbure needs a **domain of its own** (for instance `budget.example.org`): it cannot be
  installed in a sub-path.
- Keep the application **public** (visitors): the mobile apps and the daily
  synchronization call its API outside the YunoHost portal. Carbure always asks for its own
  login: its accounts are not the YunoHost accounts (no SSO).
- The YunoHost user chosen at the installation becomes the Carbure administrator, with the
  password typed here (8 characters at least).
- The installation builds [woob](https://woob.tech/), used to synchronize the banks, in a
  virtualenv: it takes a few minutes and about 500 MB.
