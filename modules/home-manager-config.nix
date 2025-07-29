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
      # 1) Load Powerlevel10k from your flake
      source "${dotfiles}/.p10k.zsh"

      # 2) Load your legacy ~/.zshrc directly from the flake
      source "${dotfiles}/.zshrc"
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
    # We no longer manage ~/.zshrc itself—just source it above—so no conflict.
    ".p10k.zsh" = { source = "${dotfiles}/.p10k.zsh"; };

    # Hyprland config + editable start script
    ".config/hypr/hyprland.conf" = { source = "${dotfiles}/hypr/hyprland.conf"; };
    ".config/hypr/start.sh"      = { source = "${dotfiles}/hypr/start.sh"; executable = true; };

    # Your other configs as recursive symlinks
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

