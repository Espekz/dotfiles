#!/bin/bash
set -e

PROJECT_NAME="$1"
BASE_DIR="$HOME/Workspace/Symfony"
PROJECT_DIR="$BASE_DIR/$PROJECT_NAME"
TEMPLATES_DIR="$HOME/dotfiles/scripts/templates"
GITHUB_USERNAME="espekz"

if [ -z "$PROJECT_NAME" ]; then
  echo "❌ Tu dois fournir un nom de projet : new-symfony mon-projet"
  exit 1
fi

echo "📁 Création du projet Symfony dans $PROJECT_DIR..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR" || exit 1

echo "🎼 Création du projet Symfony Webapp..."
symfony new "$PROJECT_NAME" --webapp

cd "$PROJECT_DIR" || exit 1

echo "📄 Génération du fichier .env Docker Compose..."
echo "PROJECT_NAME=$PROJECT_NAME" > "$PROJECT_DIR/.env"
echo ".env" >> "$PROJECT_DIR/.gitignore"

echo "📦 Copie des fichiers de configuration Docker..."
cp "$TEMPLATES_DIR/docker-compose.yml" "$PROJECT_DIR/docker-compose.yml"
cp "$TEMPLATES_DIR/nginx.conf" "$PROJECT_DIR/nginx.conf"
cp "$TEMPLATES_DIR/Makefile" "$PROJECT_DIR/Makefile"
cp "$TEMPLATES_DIR/Dockerfile" "$PROJECT_DIR/Dockerfile"

# 🔁 Remplacement du placeholder par le vrai nom de projet (version safe)
echo "🔁 Remplacement des placeholders..."
sed -i '' 's/PROJECT_NAME_PLACEHOLDER/'"$PROJECT_NAME"'/g' "$PROJECT_DIR/docker-compose.yml"
sed -i '' 's/PROJECT_NAME_PLACEHOLDER/'"$PROJECT_NAME"'/g' "$PROJECT_DIR/nginx.conf"
sed -i '' 's/PROJECT_NAME_PLACEHOLDER/'"$PROJECT_NAME"'/g' "$PROJECT_DIR/Makefile"

echo "🧪 Vérification des noms de conteneurs..."
grep container_name "$PROJECT_DIR/docker-compose.yml"

echo "🚀 Lancement des services Docker..."
docker-compose up -d --build

echo "📦 Installation des dépendances Symfony..."
docker-compose exec php composer install

echo "✅ Projet Symfony prêt dans $PROJECT_DIR"
echo "🌍 Accès : http://localhost:8080 | phpMyAdmin : http://localhost:8081"