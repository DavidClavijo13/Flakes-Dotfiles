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
    rofi-wayland mako pavucontrol rofi-pulse-select playerctl wlogout vscode claude-code
  ];

  ###########################
  # Dotfiles & Config Folders
  ###########################
  home.file = {
    # Zsh/P10k as before
    ".p10k.zsh" = { source = "${dotfiles}/.p10k.zsh"; };

    # force-manage the whole hypr directory
    ".config/hypr" = lib.mkForce {
      source    = "${dotfiles}/hypr";
      recursive = true;
    };

    ".config/hypr/toggle-waybar.sh" = {
      source     = "${dotfiles}/hypr/toggle-waybar.sh";
      executable = true;
    };

    # your other configs (ghostty, waybar, nvim)…
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
    ".config/rofi" = {
      source    = "${dotfiles}/rofi";
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

