{ config, pkgs, lib, ... }:

let
  # 1. Bind your dotfiles path once to avoid repeating ../files everywhere
  dotfiles = ../files;
in {
  home.stateVersion  = "25.05";
  home.username      = "logonix";
  home.homeDirectory = "/home/logonix";

  ###########################
  # Zsh
  ###########################
  programs.zsh = {
    enable = true;
    # 2. Use interactiveShellInit instead of an unsupported prompt option
    interactiveShellInit = ''
      # Load Powerlevel10k theme if present
      [ -f "${HOME}/.p10k.zsh" ] && source "${HOME}/.p10k.zsh"
      # Load your legacy aliases/functions
      [ -f "${HOME}/.zshrc" ] && source "${HOME}/.zshrc"
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
    # 3. Explicitly copy in your legacy dotfiles so they live in $HOME
    ".zshrc" = { source = dotfiles/.zshrc; copy = true; };
    ".p10k.zsh" = { source = dotfiles/.p10k.zsh; copy = true; };

    # 4. Keep your config directories as recursive copies
    ".config/ghostty" = { source = dotfiles/ghostty; recursive = true; copy = true; };
    ".config/hypr"    = { source = dotfiles/hypr;    recursive = true; copy = true; };
    ".config/waybar"  = { source = dotfiles/waybar;  recursive = true; copy = true; };
    ".config/nvim"    = { source = dotfiles/nvim;    recursive = true; copy = true; };
  };

  # 5. Future opportunity: if you add more modules, consider grouping similar settings
  #    (e.g. graphics, audio) into separate Nix files and importing them here.
}

