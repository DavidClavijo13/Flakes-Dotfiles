{ config, pkgs, lib, ... }:

{
  home.username      = "logonix";
  home.homeDirectory = "/home/logonix";
  home.stateVersion  = "25.05";

  programs.zsh = {
    enable = true;
    initExtra = ''
      source ${./files/.zshrc}
    '';
  };

  home.packages = with pkgs; [
    git zsh neovim ghostty wl-clipboard fzf zoxide jq bc gawk
    rofi-wayland mako pavucontrol rofi-pulse-select playerctl wlogout
  ];

  home.file = {
    ".p10k.zsh"  = { source = ./files/.p10k.zsh; };
    ".config/ghostty" = { source = ./files/ghostty; };
    ".config/hypr"    = { source = ./files/hypr; };
    ".config/nvim"    = { source = ./files/nvim; };
    ".config/waybar"  = { source = ./files/waybar; };
  };
}

