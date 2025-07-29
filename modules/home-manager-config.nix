{ config, pkgs, lib, ... }:

{
  ###########################
  # Identity & State Version
  ###########################
  home.stateVersion  = "25.05";
  home.username      = "logonix";
  home.homeDirectory = "/home/logonix";

  ###########################
  # Zsh
  ###########################
  programs.zsh = {
    enable = true;
    initExtra = ''
      # source your legacy .zshrc
      source ${../files/.zshrc}
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
  # Dotfiles & Config Folders (copy into $HOME)
  ###########################
  home.file = {
    ".p10k.zsh"       = {
      source = ../files/.p10k.zsh;
      copy   = true;
    };

    ".config/ghostty" = {
      source    = ../files/ghostty;
      recursive = true;
      copy      = true;
    };
    ".config/hypr"    = {
      source    = ../files/hypr;
      recursive = true;
      copy      = true;
    };
    ".config/waybar"  = {
      source    = ../files/waybar;
      recursive = true;
      copy      = true;
    };
    ".config/nvim"    = {
      source    = ../files/nvim;
      recursive = true;
      copy      = true;
    };
  };
}

