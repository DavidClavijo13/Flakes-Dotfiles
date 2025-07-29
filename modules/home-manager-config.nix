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
      [ -f "$HOME/.p10k.zsh" ] && source "$HOME/.p10k.zsh"
      [ -f "$HOME/.zshrc"    ] && source "$HOME/.zshrc"
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
    # Core dotfiles
    ".zshrc"    = lib.mkForce { source = "${dotfiles}/.zshrc"; };
    ".p10k.zsh" =             { source = "${dotfiles}/.p10k.zsh"; };

    # Other configs (symlink directories)
    ".config/ghostty" = {
      source    = "${dotfiles}/ghostty";
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

    # Hyprland config and start script
    ".config/hypr/hyprland.conf" = {
      source = "${dotfiles}/hypr/hyprland.conf";
    };
    ".config/hypr/start.sh" = {
      source    = "${dotfiles}/hypr/start.sh";
      executable = true;
    };
  };

  ###########################
  # One-shot: copy nvim config so Lazy.nvim can write lockfiles
  ###########################
  home.activation.copyNvim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "$HOME/.config/nvim" ]; then
      cp -r ${dotfiles}/nvim "$HOME/.config/nvim"
    fi
  '';
}

