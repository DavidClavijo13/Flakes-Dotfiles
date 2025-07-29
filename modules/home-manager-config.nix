{ config, pkgs, lib, ... }:

let
  # where your real nvim config lives in the flake
  nvimSrc = ../files/nvim;
in {
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
    # after HM’s own setup, drop into your legacy .zshrc
    initExtra = ''
      source ${../files/.zshrc}
    '';
  };

  ###########################
  # User‐level Packages
  ###########################
  home.packages = with pkgs; [
    git zsh neovim ghostty wl-clipboard fzf zoxide jq bc gawk
    rofi-wayland mako pavucontrol rofi-pulse-select playerctl wlogout
  ];

  ###########################
  # Dotfiles & Config Folders
  ###########################
  home.file = {
    ".p10k.zsh"       = { source = ../files/.p10k.zsh; };

    # recursive = true pulls in the entire folder tree
    ".config/ghostty" = { source = ../files/ghostty; recursive = true; };
    ".config/hypr"    = { source = ../files/hypr;    recursive = true; };
    ".config/waybar"  = { source = ../files/waybar;  recursive = true; };
    ".config/nvim"    = { source = ../files/nvim;    recursive = true; };
  };

  ########################################
  # Activation: copy nvim into a writeable directory
  ########################################
  home.activation.copyNvimConfig = lib.dag.entryAfter [ "writeBoundary" ] ''
    # remove any old symlink or dir
    rm -rf "$HOME/.config/nvim"
    mkdir -p "$HOME/.config"
    # copy *your* config into place as a normal folder
    cp -r ${nvimSrc} "$HOME/.config/nvim"
  '';
}

