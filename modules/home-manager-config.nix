{ config, pkgs, lib, ... }:

let
  dotfiles = ../files;    # points at ~/dotfiles/files
in {
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
      # 1) Load P10k if present
      [ -f "$HOME/.p10k.zsh" ] && source "$HOME/.p10k.zsh"
      # 2) Then your legacy ~/.zshrc
      [ -f "$HOME/.zshrc" ]    && source "$HOME/.zshrc"
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
    # only one .zshrc entry—drop any others you have!
    ".zshrc"    = { source = dotfiles/.zshrc;    };
    ".p10k.zsh" = { source = dotfiles/.p10k.zsh; };

    ".config/ghostty" = {
      source    = dotfiles/ghostty;
      recursive = true;
    };
    ".config/hypr" = {
      source    = dotfiles/hypr;
      recursive = true;
    };
    ".config/waybar" = {
      source    = dotfiles/waybar;
      recursive = true;
    };
  };

  ###########################
  # One-shot: copy writable nvim dir
  ###########################
  home.activation.copyNvim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "$HOME/.config/nvim" ]; then
      cp -r ${dotfiles}/nvim "$HOME/.config/nvim"
    fi
  '';
}

