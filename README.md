# Dotfiles - by espekz

Ce dépôt contient mes fichiers de configuration personnels pour mon environnement de développement sur macOS, ainsi que quelques scripts pratiques pour automatiser la création de projets Symfony avec Docker.

---

## 📁 Contenu du dépôt

- `.zshrc` : configuration du shell Zsh
- `.p10k.zsh` : configuration thématique pour le prompt Powerlevel10k *(optionnel)*
- `scripts/` : scripts utilitaires personnalisés
  - `new-symfony.sh` : gère la création automatique d'un projet Symfony avec environnement Docker prêt à l'emploi

---

## ⚙️ Installation sur un nouvel ordinateur

Un script `install.sh` est prévu pour initialiser rapidement l'environnement sur une nouvelle machine :

```bash
./install.sh
```

Il :
- Clone ce dépôt dans `~/dotfiles`
- Copie `.zshrc` et `.p10k.zsh` à la racine de l'utilisateur
- Recharge la config shell automatiquement

---

## 🧰 Script `new-symfony`

Le script `new-symfony.sh` automatise les étapes suivantes :

1. Création d'un nouveau projet Symfony WebApp dans `~/Workspace/Symfony/NOM_DU_PROJET`
2. Initialisation Docker :
   - Récupération d'un template `docker-compose.yml`, `nginx.conf` et `Makefile`
   - Lancement des services via `docker-compose`
3. Installation des dépendances Symfony via `composer install`
4. Initialisation git + push automatique sur GitHub (branche `master`)

### Exemple d'utilisation :
```bash
new-symfony mon-nouveau-projet
```

### Alias

Un alias `new-symfony` est ajouté automatiquement dans `.zshrc` pour accéder au script facilement :
```bash
alias new-symfony="~/dotfiles/scripts/new-symfony.sh"
```

---

## 🌍 Infos utiles

- Le projet Symfony est accessible via http://localhost:8080
- PhpMyAdmin est disponible via http://localhost:8081 (si utilisé)
- Les identifiants par défaut sont : `espeka` / `espeka` pour MySQL

---

## 🧑‍💻 Auteur

> Ce repo est maintenu par **[@espekz](https://github.com/espekz)**.
