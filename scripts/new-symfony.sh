#!/bin/bash

set -e

PROJECT_NAME=$1
BASE_DIR=~/Workspace/Symfony
PROJECT_DIR="$BASE_DIR/$PROJECT_NAME"
GITHUB_USERNAME="espekz"
LOG_FILE="$PROJECT_DIR/log.txt"

if [ -z "$PROJECT_NAME" ]; then
  echo "❌ Merci de préciser un nom de projet : new-symfony mon-projet"
  exit 1
fi

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Symfony project creation
symfony new "$PROJECT_NAME" --webapp 2>> "$LOG_FILE"
cd "$PROJECT_NAME"

# Initialize git and GitHub
git init 2>> "$LOG_FILE"
git checkout -b master 2>> "$LOG_FILE"
echo -e "# $PROJECT_NAME\n" > README.md

git add .
git commit -m "Initial commit" 2>> "$LOG_FILE"
gh repo create "$GITHUB_USERNAME/$PROJECT_NAME" --private --source=. --remote=origin --push 2>> "$LOG_FILE"

# Copy base docker setup from dotfiles
cp ~/dotfiles/templates/docker-compose.yml . 2>> "$LOG_FILE"
cp ~/dotfiles/templates/nginx.conf . 2>> "$LOG_FILE"
cp ~/dotfiles/templates/Makefile . 2>> "$LOG_FILE"

# Setup .env
cp .env .env.local 2>> "$LOG_FILE"
sed -i '' "s/DATABASE_URL=.*/DATABASE_URL=mysql:\/\/espeka:espeka@mysql:3306\/$PROJECT_NAME?serverVersion=8.0.32&charset=utf8mb4/" .env.local 2>> "$LOG_FILE"

# Launch containers
make build 2>> "$LOG_FILE"
make start 2>> "$LOG_FILE"

# Wait for MySQL to be ready
sleep 10

# Create database & migration setup
make doctrine-init 2>> "$LOG_FILE"

# Add HomeController & Fixtures
mkdir -p src/Controller src/DataFixtures templates 2>> "$LOG_FILE"
echo '<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class HomeController extends AbstractController
{
    #[Route("/", name: "home")]
    public function index(): Response
    {
        return $this->render("base.html.twig");
    }
}' > src/Controller/HomeController.php

echo '<?php

namespace App\DataFixtures;

use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;

class AppFixtures extends Fixture
{
    public function load(ObjectManager $manager): void
    {
        // Fixtures de base ici
    }
}' > src/DataFixtures/AppFixtures.php

echo '<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bienvenue</title>
</head>
<body>
    <h1>Bienvenue dans $PROJECT_NAME 🎉</h1>
</body>
</html>' > templates/base.html.twig

echo "\n✅ Projet $PROJECT_NAME prêt ! Accès : http://localhost:8080 | phpMyAdmin : http://localhost:8081"
