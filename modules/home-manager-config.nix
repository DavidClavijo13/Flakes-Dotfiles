{ config, pkgs, lib, ... }:

let
  # Path to your dotfiles’ nvim folder
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
    initExtra = ''
      # Ensure ~/.config/nvim is a writeable copy of your flake files
      if [ ! -d "$HOME/.config/nvim" ] || [ ! -w "$HOME/.config/nvim" ]; then
        rm -rf "$HOME/.config/nvim"
        mkdir -p "$HOME/.config"
        cp -r ${../files/nvim} "$HOME/.config/nvim"
      fi

      # Finally, source your legacy .zshrc
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
  # Dotfiles & Config Folders
  ###########################
  home.file = {
    ".p10k.zsh"       = { source = ../files/.p10k.zsh; };

    ".config/ghostty" = { source = ../files/ghostty; recursive = true; };
    ".config/hypr"    = { source = ../files/hypr;    recursive = true; };
    ".config/waybar"  = { source = ../files/waybar;  recursive = true; };
    ".config/nvim"    = { source = ../files/nvim;    recursive = true; };
  };

}

