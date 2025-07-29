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
    enable = true;
    initExtra = ''
      # 1) Load Powerlevel10k if present
      if [ -f "$HOME/.p10k.zsh" ]; then
        source "$HOME/.p10k.zsh"
      fi

      # 2) Then load your legacy aliases/functions from .zshrc_custom
      if [ -f "$HOME/.zshrc_custom" ]; then
        source "$HOME/.zshrc_custom"
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
    # Your legacy zshrc is now renamed to .zshrc_custom
    ".zshrc_custom" = { source = dotfiles/.zshrc; };
    ".p10k.zsh"     = { source = dotfiles/.p10k.zsh; };

    # Other config folders (symlinked)
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
  # One-shot activation: copy nvim config for Lazy.nvim to write into
  ###########################
  home.activation.copyNvim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "$HOME/.config/nvim" ]; then
      cp -r ${dotfiles}/nvim "$HOME/.config/nvim"
    fi
  '';
}

