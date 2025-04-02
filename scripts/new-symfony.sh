#!/bin/bash

set -e

# === CONFIG ===
PROJECT_NAME="$1"
BASE_DIR="$HOME/Workspace/Symfony"
PROJECT_DIR="$BASE_DIR/$PROJECT_NAME"
GITHUB_USER="espekz"

if [ -z "$PROJECT_NAME" ]; then
  echo "❌ Tu dois fournir un nom de projet : new-symfony mon-projet"
  exit 1
fi

echo "📁 Création du dossier projet dans $PROJECT_DIR..."
mkdir -p "$PROJECT_DIR"
cd "$BASE_DIR"

echo "🎼 Génération du projet Symfony Webapp..."
symfony new "$PROJECT_NAME" --webapp

cd "$PROJECT_DIR"

echo "⚙️ Copie des templates Docker..."
cp ~/dotfiles/scripts/templates/docker-compose.yml ./docker-compose.yml
cp ~/dotfiles/scripts/templates/nginx.conf ./nginx.conf
cp ~/dotfiles/scripts/templates/Makefile ./Makefile

echo "🛠 Remplacement du nom du projet dans docker-compose.yml..."
sed -i '' "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" docker-compose.yml

echo "🚀 Lancement des services Docker..."
docker-compose up -d --build

echo "📦 Installation des dépendances Symfony..."
docker-compose exec php composer install

echo "✅ Projet Symfony '$PROJECT_NAME' prêt !"
echo "🌍 Accès : http://localhost:8080 | phpMyAdmin : http://localhost:8081 (user: espeka, mdp: espeka)"