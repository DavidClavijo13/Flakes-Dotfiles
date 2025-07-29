# modules/home-manager-config.nix

{ config, pkgs, lib, ... }:

let
  # 1) Point ‘dotfiles’ at your ~/dotfiles/files directory, not the flake root.
  dotfiles = ../files;
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
      # Load Powerlevel10k if present
      [ -f "$HOME/.p10k.zsh" ] && source "$HOME/.p10k.zsh"
      # Then load your legacy ~/.zshrc
      [ -f "$HOME/.zshrc"    ] && source "$HOME/.zshrc"
    '';
  };

  ###########################
  # Packages
  ###########################
  home.packages = with pkgs; [
    git zsh neovim ghostty wl-clipboard fzf zoxide jq bc gawk
    rofi-wayland mako pavucontrol rofi-pulse-select playerctl wlogout
  ];

  ###########################
  # Dotfiles & Config Folders
  ###########################
  home.file = {
    # 2) Override the built-in ~/.zshrc with your file from dotfiles/files
    ".zshrc" = lib.mkForce {
      source = "${dotfiles}/.zshrc";  # references ~/dotfiles/files/.zshrc
    };

    # 3) Bring in your Powerlevel10k config from dotfiles/files
    ".p10k.zsh" = {
      source = "${dotfiles}/.p10k.zsh";  # references ~/dotfiles/files/.p10k.zsh
    };

    # 4) Symlink your other config directories from dotfiles/files
    ".config/ghostty" = {
      source    = "${dotfiles}/ghostty";
      recursive = true;
    };
    ".config/hypr" = {
      source    = "${dotfiles}/hypr";
      recursive = true;
    };
    ".config/waybar" = {
      source    = "${dotfiles}/waybar";
      recursive = true;
    };
    ".config/nvim" = {
      source    = "${dotfiles}/nvim";
      recursive = true;
    };
  };

  ###########################
  # One-shot: copy nvim for Lazy.nvim writes
  ###########################
  home.activation.copyNvim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "$HOME/.config/nvim" ]; then
      cp -r ${dotfiles}/nvim "$HOME/.config/nvim"
    fi
  '';
}

