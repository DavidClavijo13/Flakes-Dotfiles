# modules/home-manager-config.nix

{ config, pkgs, lib, ... }:

let
  dotfiles = ../files;  # points at ~/dotfiles/files
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
    enable    = true;
    initExtra = ''
      # 1) Source your Powerlevel10k config directly from the flake
      [ -f "${dotfiles}/.p10k.zsh" ] && source "${dotfiles}/.p10k.zsh"

      # 2) Source your legacy .zshrc directly from the flake
      [ -f "${dotfiles}/.zshrc" ]    && source "${dotfiles}/.zshrc"
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
    # Only manage the files you need in $HOME; no .zshrc here, so we avoid conflicts.
    ".p10k.zsh" = { source = "${dotfiles}/.p10k.zsh"; };

    # Other config directories (symlinked from your flake)
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
  # One-shot activation: copy nvim directory
  ###########################
  home.activation.copyNvim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "$HOME/.config/nvim" ]; then
      cp -r ${dotfiles}/nvim "$HOME/.config/nvim"
    fi
  '';
}

