# Dotfiles & Scripts - Espeka

Bienvenue dans mon repository de dotfiles personnalisés. Ce repo contient divers fichiers de configuration ainsi que des scripts pour automatiser la création de projets Symfony avec Docker, GitHub et bonnes pratiques.

## Structure du repo

```
.
├── aliases.zsh             # Alias Zsh utilisés au quotidien
├── scripts/
│   └── new-symfony.sh      # Script principal pour créer un projet Symfony automatiquement
├── templates/
│   ├── docker-compose.yml  # Template de docker-compose personnalisé
│   ├── nginx.conf          # Config nginx
│   ├── Makefile            # Outils make pour gestion projet
│   └── .env.template       # Template .env prêt à l'emploi
```

## Script : `new-symfony`

### Usage
```bash
new-symfony nom-du-projet
```

Ce script fait tout pour vous :

- Crée un nouveau projet Symfony via `symfony new` dans `~/Workspace/Symfony/`
- Gère toute l’intégration Docker avec MySQL, PHP, Nginx, phpMyAdmin
- Configure automatiquement le fichier `.env` (base de données, user, etc)
- Installe des outils utiles : Doctrine Migrations, PHPStan, PHPUnit, Fixtures
- Démarre les conteneurs Docker
- Initialise un dépôt Git local et le push automatiquement sur GitHub sur `master`

### Prérequis
- Symfony CLI installé
- Docker installé et en fonctionnement
- Compte GitHub configuré avec un token personnel (scope: `repo`) dans le gestionnaire de clés
- Un fichier `~/.config/gh/hosts.yml` ou `gh auth login` préalablement exécuté

### Infos utiles
- La base de données porte le nom du projet (ex: `mon-projet_test`) et le user par défaut est `espeka`
- Un fichier `log.txt` est généré dans le dossier du projet contenant uniquement les erreurs
- L’accès phpMyAdmin est disponible sur `http://localhost:8081`

## Makefile - Commandes utiles
Voici les commandes `make` disponibles dans tous les projets créés :

```bash
make up         # Démarre le projet (docker-compose up -d --build)
make down       # Arrête les conteneurs
make logs       # Affiche les logs des conteneurs
make shell      # Ouvre un shell dans le conteneur PHP
make db         # Accès à MySQL via CLI
make migrate    # Lance les migrations Doctrine
make fixtures   # Charge les fixtures
make test       # Lance les tests PHPUnit
make phpstan    # Analyse statique avec PHPStan
```

## TODO
- Ajouter une commande pour la suppression complète d’un projet
- Ajouter d’autres templates (API Platform, Laravel, etc.)

---

N’hésitez pas à forker et adapter selon vos besoins !

**Auteur : [espekz](https://github.com/espekz)**

