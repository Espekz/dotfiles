#!/bin/bash

echo "🚀 Installation des dotfiles..."

git clone git@github.com:espekz/dotfiles.git ~/dotfiles
cd ~/dotfiles || exit 1

cp .zshrc ~/.zshrc
cp .p10k.zsh ~/.p10k.zsh 2>/dev/null

source ~/.zshrc

echo "✅ Dotfiles installés avec succès !"
