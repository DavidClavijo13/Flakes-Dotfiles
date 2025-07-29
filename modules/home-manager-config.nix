{ config, pkgs, lib, ... }:

let
  # centralize your dotfiles directory
  dotfiles = ../files;
  homeDir  = "/home/logonix";    # or: config.home.homeDirectory
in {
  ###########################
  # Identity & State Version
  ###########################
  home.stateVersion  = "25.05";
  home.username      = "logonix";
  home.homeDirectory = homeDir;

  ###########################
  # Zsh + Powerlevel10k
  ###########################
  programs.zsh.enable = true;
  programs.zsh.interactiveShellInit = ''
    # 1) Load Powerlevel10k if it’s been copied in
    if [ -f "${homeDir}/.p10k.zsh" ]; then
      source "${homeDir}/.p10k.zsh"
    fi

    # 2) Then load your legacy aliases/functions
    if [ -f "${homeDir}/.zshrc" ]; then
      source "${homeDir}/.zshrc"
    fi
  '';

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
    ".zshrc"    = { source = dotfiles/.zshrc;    copy = true; };
    ".p10k.zsh" = { source = dotfiles/.p10k.zsh; copy = true; };

    # your existing configs as recursive copies
    ".config/ghostty" = {
      source    = dotfiles/ghostty;
      recursive = true;
      copy      = true;
    };
    ".config/hypr" = {
      source    = dotfiles/hypr;
      recursive = true;
      copy      = true;
    };
    ".config/waybar" = {
      source    = dotfiles/waybar;
      recursive = true;
      copy      = true;
    };
    ".config/nvim" = {
      source    = dotfiles/nvim;
      recursive = true;
      copy      = true;
    };
  };
}

