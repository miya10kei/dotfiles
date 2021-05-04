#!/bin/env bash

function linkDotfiles() {
  mkdir -p $HOME/.config/coc/extensions $HOME/.config/fish

  local -r DOT_DIR=$HOME/.dotfiles

  ln -fs $DOT_DIR/.editorconfig      $HOME/.editorconfig
  ln -fs $DOT_DIR/.gitconfig         $HOME/.gitconfig
  ln -fs $DOT_DIR/.gitconfig_private $HOME/.gitconfig_private
  ln -fs $DOT_DIR/.hyper.js          $HOME/.hyper.js
  ln -fs $DOT_DIR/.ideavimrc         $HOME/.ideavimrc
  ln -fs $DOT_DIR/.npmrc             $HOME/.npmrc
  ln -fs $DOT_DIR/.tmux.conf         $HOME/.tmux.conf
  ln -fs $DOT_DIR/coc-package.json   $HOME/.config/coc/extensions/package.json
  ln -fs $DOT_DIR/coc-settings.json  $HOME/.config/coc/coc-settings.json
  ln -fs $DOT_DIR/config.fish        $HOME/.config/fish/config.fish
  ln -fs $DOT_DIR/fishfile           $HOME/.config/fish/fishfile
  ln -fs $DOT_DIR/init.vim           $HOME/.config/nvim/init.vim
  ln -fs $DOT_DIR/package.json       $HOME/package.json
}
