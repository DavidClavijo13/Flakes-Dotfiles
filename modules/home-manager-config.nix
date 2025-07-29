{ config, pkgs, lib, ... }:

let
  # Path to your dotfiles tree
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
    enable     = true;
    # After HM’s own init, source your legacy .zshrc:
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
  # Dotfile & Config Folder Symlinks
  ###########################
  home.file = {
    ".p10k.zsh"       = { source = ../files/.p10k.zsh; };

    # These folders will be fully (recursively) managed
    ".config/ghostty" = { source = ../files/ghostty; recursive = true; };
    ".config/hypr"    = { source = ../files/hypr;    recursive = true; };
    ".config/waybar"  = { source = ../files/waybar;  recursive = true; };
  };

  ########################################
  # Activation: Copy nvim into a writeable dir
  ########################################
  home.activation.copyNvimConfig = lib.mkAfter "copy-nvim-config" ''
    # remove any old symlink
    rm -rf "$HOME/.config/nvim"
    mkdir -p "$HOME/.config"
    # copy your nvim tree into a real folder
    cp -r ${nvimSrc} "$HOME/.config/nvim"
  '';
}

