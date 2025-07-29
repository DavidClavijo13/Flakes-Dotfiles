{ config, pkgs, lib, ... }:

{
  # ── Identity ───────────────────────────────────────────────────────────────
  home.stateVersion  = "25.05";
  home.username      = "logonix";
  home.homeDirectory = "/home/logonix";

  # ── Shell & Prompt ──────────────────────────────────────────────────────────
  programs.zsh = {
    enable     = true;
    # HM will install zsh, set up completions/prompts, then:
    initContent = ''
      # source your existing .zshrc for all your custom bits:
      source ${../files/.zshrc}
    '';
  };

  # ── User‐level Packages ─────────────────────────────────────────────────────
  home.packages = with pkgs; [
    git zsh neovim ghostty wl-clipboard fzf zoxide jq bc gawk
    rofi-wayland mako pavucontrol rofi-pulse-select playerctl wlogout
  ];

  # ── Symlink Your dotfiles & Config Folders ──────────────────────────────────
  home.file = {
    ".p10k.zsh"       = { source = ../files/.p10k.zsh; };

    ".config/ghostty" = { source = ../files/ghostty; };
    ".config/hypr"    = { source = ../files/hypr; };
    ".config/waybar"  = { source = ../files/waybar; };
  };

  let
    nvimSrc = ./files/nvim;
  in {

  # Copy nvim config out of the store into a real ~/.config/nvim
    home.activation.copyNvimConfig = lib.mkAfter "copy-nvim-config" ''
     rm -rf "$HOME/.config/nvim"
     mkdir -p "$HOME/.config"
      cp -r ${nvimSrc} "$HOME/.config/nvim"
    '';

  # … any other activations …
  }
}

