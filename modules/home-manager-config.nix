{ config, pkgs, lib, ... }:

{
  ###########################
  # Identity & State Version
  ###########################
  home.stateVersion  = "25.05";
  home.username      = "logonix";
  home.homeDirectory = "/home/logonix";

  ###########################
  # Zsh + Powerlevel10k
  ###########################
  programs.zsh = {
    enable = true;
    initExtra = ''
      # 1) Load Powerlevel10k if it was copied into your home
      if [ -f "$HOME/.p10k.zsh" ]; then
        source "$HOME/.p10k.zsh"
      fi

      # 2) Then load your legacy aliases/functions
      if [ -f "$HOME/.zshrc" ]; then
        source "$HOME/.zshrc"
      fi
    '';
  };

  ###########################
  # User-level Packages
  ###########################
  home.packages = with pkgs; [
    git zsh neovim ghostty wl-clipboard fzf zoxide jq bc gawk
    rofi-wayland mako pavucontrol rofi-pulse-select playerctl wlogout
  ];

  ###########################
  # Dotfiles & Config Folders
  ###########################
  home.file = {
    # ensure these live in your real $HOME
    ".zshrc"    = { source = ../files/.zshrc;    copy = true; };
    ".p10k.zsh" = { source = ../files/.p10k.zsh; copy = true; };

    # your existing configs as recursive copies
    ".config/ghostty" = {
      source    = ../files/ghostty;
      recursive = true;
      copy      = true;
    };
    ".config/hypr" = {
      source    = ../files/hypr;
      recursive = true;
      copy      = true;
    };
    ".config/waybar" = {
      source    = ../files/waybar;
      recursive = true;
      copy      = true;
    };
    ".config/nvim" = {
      source    = ../files/nvim;
      recursive = true;
      copy      = true;
    };
  };
}

