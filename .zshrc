# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  docker
  docker-compose
  symfony
  z
  alias-finder
  command-not-found
  web-search
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias home="cd ~"

# Git
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gl="git log --oneline --graph --decorate --all"

# Docker
alias dcu="docker-compose up -d"
alias dcd="docker-compose down"
alias dcb="docker-compose build"
alias dce="docker-compose exec"

# Symfony (si installé dans le conteneur)
alias sf="docker exec -it symfony_php php bin/console"
alias new-symfony="~/dotfiles/scripts/new-symfony.sh"
alias pma="open http://localhost:8081"

function update-dotfiles() {
  cd ~/dotfiles || return
  cp ~/.zshrc .
  cp ~/.p10k.zsh . 2>/dev/null
  git add .
  git commit -m "🔄 Mise à jour automatique des dotfiles ($(date '+%Y-%m-%d %H:%M'))"
  git push
  echo "✅ Dotfiles mis à jour sur GitHub."
}

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
