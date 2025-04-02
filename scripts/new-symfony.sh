#!/bin/bash

PROJECT_NAME="$1"
BASE_DIR="$HOME/Workspace/Symfony"
PROJECT_DIR="$BASE_DIR/$PROJECT_NAME"
LOG_FILE="$PROJECT_DIR/log.txt"

if [ -z "$PROJECT_NAME" ]; then
  echo "❌ Tu dois fournir un nom de projet : new-symfony mon-projet"
  exit 1
fi

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR" || exit 1

# Rediriger toutes les sorties vers le fichier log.txt
exec > >(tee "$LOG_FILE") 2>&1

# === DOCKER SETUP ===
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

cat <<NGINX > nginx.conf
server {
    listen 80;
    server_name localhost;
    root /var/www/html/public;
    index index.php index.html;

    location / {
        try_files \$uri /index.php\$is_args\$args;
    }

    location ~ \.php\$ {
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

# === LANCER DOCKER ===
echo "🚀 Lancement des services Docker..."
docker-compose up -d --build

echo "⏳ Attente du conteneur PHP..."
until docker exec -it ${PROJECT_NAME}_php true 2>/dev/null; do
  sleep 1
done

# === INSTALLER SYMFONY ===
docker exec -it ${PROJECT_NAME}_php bash -c "apt-get update && apt-get install -y unzip git curl && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && composer create-project symfony/webapp ."

# === CONFIG .ENV ===
sed -i '' "s|DATABASE_URL=\"sqlite:///%%kernel.project_dir%%/var/data.db\"|DATABASE_URL=\"mysql://espeka:espeka@db:3306/${PROJECT_NAME}\"|" .env

# === AJOUT TWIG + CONTROLLER ===
mkdir -p templates
cat <<TWIG > templates/base.html.twig
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>{% block title %}Accueil{% endblock %}</title></head>
<body><h1>Bienvenue sur ${PROJECT_NAME}</h1>{% block body %}{% endblock %}</body>
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

# === INSTALL MIGRATIONS + FIXTURES + PHPUNIT + PHPSTAN ===
docker exec -it ${PROJECT_NAME}_php composer require doctrine/doctrine-migrations-bundle doctrine/doctrine-fixtures-bundle --dev

docker exec -it ${PROJECT_NAME}_php composer require --dev phpunit/phpunit phpstan/phpstan

docker exec -it ${PROJECT_NAME}_php bin/console make:migration

# === FIXTURE DE BASE ===
mkdir -p src/DataFixtures
cat <<PHP > src/DataFixtures/AppFixtures.php
<?php
namespace App\DataFixtures;

use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;

class AppFixtures extends Fixture
{
    public function load(ObjectManager \$manager): void
    {
        // Ajoute tes entités ici
    }
}
PHP

# === MAKEFILE ===
cat <<MAKE > Makefile
up:
	docker-compose up -d

stop:
	docker-compose down

restart:
	make stop
	make up

logs:
	docker-compose logs -f

bash:
	docker-compose exec php bash

console:
	docker-compose exec php php bin/console

test:
	docker-compose exec php php bin/phpunit

phpstan:
	docker-compose exec php vendor/bin/phpstan analyse src --level=max

migrate:
	docker-compose exec php php bin/console doctrine:migrations:migrate --no-interaction

fixtures:
	docker-compose exec php php bin/console doctrine:fixtures:load --no-interaction

fresh:
	docker-compose down -v
	docker-compose up -d --build
	docker-compose exec php php bin/console doctrine:database:create --if-not-exists
	docker-compose exec php php bin/console doctrine:migrations:migrate --no-interaction
	docker-compose exec php php bin/console doctrine:fixtures:load --no-interaction
MAKE

# === INIT GIT + CREATION DEPOT GITHUB ===
git init
git checkout -b master
git add .
git commit -m "Initial commit"

# Crée le dépôt GitHub et push
if command -v gh &> /dev/null; then
  gh repo create "$PROJECT_NAME" --public --source=. --remote=origin --push
else
  echo "⚠️  GitHub CLI (gh) non trouvé. Skipping repo creation."
fi

echo "\n✅ Projet ${PROJECT_NAME} prêt ! Accès : http://localhost:8080 | phpMyAdmin : http://localhost:8081"
echo "📄 Tous les logs de cette installation sont disponibles ici : $LOG_FILE"
