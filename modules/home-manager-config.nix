{ config, pkgs, lib, ... }:

let
  dotfiles = ../files;               # your local ~/dotfiles/files
  homeDir  = "/home/logonix";
in {
  ###########################
  # Identity & State Version
  ###########################
  home.stateVersion  = "25.05";
  home.username      = "logonix";
  home.homeDirectory = homeDir;

  ###########################
  # Zsh + Powerlevel10k
  ###########################
  programs.zsh = {
    enable    = true;
    initExtra = ''
      # 1) source P10k if present
      [ -f "$HOME/.p10k.zsh" ] && source "$HOME/.p10k.zsh"
      # 2) then your legacy zshrc
      [ -f "$HOME/.zshrc" ]    && source "$HOME/.zshrc"
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
    # simple files—symlinked from the Nix store
    ".zshrc"    = { source = dotfiles/.zshrc;    };
    ".p10k.zsh" = { source = dotfiles/.p10k.zsh; };

    # configs you won’t write into—recursive symlinks
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
  # Activation hook to copy nvim config
  ###########################
  # On the first `home-manager switch`, copy the whole tree
  home.activation.copyNvim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "$HOME/.config/nvim" ]; then
      cp -r ${dotfiles}/nvim "$HOME/.config/nvim"
    fi
  '';
}

