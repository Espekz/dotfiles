#!/bin/bash

# === CONFIG ===
GITHUB_USER="espekz"
REPO_NAME="dotfiles"
REPO_URL="git@github.com:$GITHUB_USER/$REPO_NAME.git"

# === ETAPE 1 : CREER LE DOSSIER DOTFILES ===
echo "\n📁 Création du dossier ~/dotfiles..."
mkdir -p ~/dotfiles
cd ~/dotfiles || exit 1

# === ETAPE 2 : COPIER LES FICHIERS DE CONFIGURATION ===
echo "\n📄 Copie des fichiers de configuration..."
cp ~/.zshrc .
cp ~/.p10k.zsh . 2>/dev/null || echo "⚠️  Aucun fichier .p10k.zsh trouvé (config Powerlevel10k)"

# === ETAPE 3 : INITIALISATION GIT ===
echo "\n🔧 Initialisation du dépôt git..."
git init
git add .
git commit -m "Initial commit - Mes dotfiles"

# === ETAPE 4 : AJOUT DU REMOTE ===
echo "\n🔗 Ajout du remote GitHub..."
git remote add origin "$REPO_URL"
git branch -M main
git push -u origin main

# === SCRIPT D'INSTALLATION POUR AUTRE ORDI ===
echo "\n📝 Création d'un script install.sh..."
cat <<EOF > install.sh
#!/bin/bash

echo "🚀 Installation des dotfiles..."

git clone $REPO_URL ~/dotfiles
cd ~/dotfiles || exit 1

cp .zshrc ~/.zshrc
cp .p10k.zsh ~/.p10k.zsh 2>/dev/null

source ~/.zshrc

echo "✅ Dotfiles installés avec succès !"
EOF
chmod +x install.sh

# === AJOUT ALIAS new-symfony DANS .zshrc ===
echo "\n⚙️ Ajout de l'alias 'new-symfony' et 'pma' dans ~/.zshrc..."
cat <<'EOF' >> ~/.zshrc

function new-symfony() {
  PROJECT_NAME="$1"
  BASE_DIR="$HOME/Workspace/Symfony"
  PROJECT_DIR="$BASE_DIR/$PROJECT_NAME"

  if [ -z "$PROJECT_NAME" ]; then
    echo "❌ Tu dois fournir un nom de projet : new-symfony mon-projet"
    return 1
  fi

  echo "📁 Création du projet Symfony dans $PROJECT_DIR..."
  mkdir -p "$PROJECT_DIR"
  cd "$PROJECT_DIR" || exit 1

  echo "🛆 Initialisation de la structure Docker..."

  # docker-compose.yml
  cat <<YAML > docker-compose.yml
version: '3.8'
services:
  php:
    image: php:8.2-fpm
    container_name: ${PROJECT_NAME}_php
    working_dir: /var/www/html
    volumes:
      - ./:/var/www/html
    depends_on:
      - db

  nginx:
    image: nginx:stable-alpine
    container_name: ${PROJECT_NAME}_nginx
    ports:
      - "8080:80"
    volumes:
      - ./:/var/www/html
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - php

  db:
    image: mysql:8.0
    container_name: ${PROJECT_NAME}_db
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: ${PROJECT_NAME}
      MYSQL_USER: espeka
      MYSQL_PASSWORD: espeka
    volumes:
      - db_data:/var/lib/mysql
    ports:
      - "3306:3306"

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: ${PROJECT_NAME}_phpmyadmin
    ports:
      - "8081:80"
    environment:
      PMA_HOST: db
      MYSQL_ROOT_PASSWORD: root

volumes:
  db_data:
YAML

  # NGINX config
  cat <<NGINX > nginx.conf
server {
    listen 80;
    server_name localhost;
    root /var/www/html/public;
    index index.php index.html;

    location / {
        try_files \$uri /index.php\$is_args\$args;
    }

    location ~ \\.php\$ {
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
    }

    location ~ /\.ht {
        deny all;
    }
}
NGINX

  echo "🚀 Lancement des services Docker..."
  docker-compose up -d --build

  echo "🎼 Création du projet Symfony Webapp..."
  docker exec -it ${PROJECT_NAME}_php bash -c "apt-get update && apt-get install -y unzip git curl && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && composer create-project symfony/webapp ."

  echo "🔧 Configuration du .env Symfony..."
  sed -i '' "s|DATABASE_URL=\"sqlite:///%%kernel.project_dir%%/var/data.db\"|DATABASE_URL=\"mysql://espeka:espeka@db:3306/${PROJECT_NAME}\"|" .env

  echo "📄 Ajout d’un layout Twig + page d’accueil..."
  mkdir -p templates/base
  cat <<TWIG > templates/base.html.twig
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>{% block title %}Bienvenue{% endblock %}</title>
  </head>
  <body>
    <header><h1>Mon projet Symfony : ${PROJECT_NAME}</h1></header>
    <main>{% block body %}{% endblock %}</main>
  </body>
</html>
TWIG

  mkdir -p src/Controller
  cat <<PHP > src/Controller/HomeController.php
<?php
namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class HomeController extends AbstractController
{
    #[Route('/', name: 'home')]
    public function index(): Response
    {
        return \$this->render('base.html.twig');
    }
}
PHP

  echo "🧪 Ajout d’un test fonctionnel..."
  mkdir -p tests/Controller
  cat <<PHP > tests/Controller/HomeControllerTest.php
<?php
namespace App\Tests\Controller;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;

class HomeControllerTest extends WebTestCase
{
    public function testHomePage(): void
    {
        \$client = static::createClient();
        \$client->request('GET', '/');

        \$this->assertResponseIsSuccessful();
        \$this->assertSelectorTextContains('h1', 'Mon projet Symfony');
    }
}
PHP

  echo "🛠 Création d'un Makefile..."
  cat <<MAKE > Makefile
up:
	docker-compose up -d

down:
	docker-compose down

bash:
	docker-compose exec php bash

console:
	docker-compose exec php php bin/console

test:
	docker-compose exec php php bin/phpunit

migrate:
	docker-compose exec php php bin/console doctrine:migrations:migrate --no-interaction
MAKE

  echo "✅ Projet Symfony Webapp prêt à l'emploi dans $PROJECT_DIR"
  echo "🌍 Accès : http://localhost:8080 | phpMyAdmin : http://localhost:8081 (user: espeka, mdp: espeka)"
}
EOF
