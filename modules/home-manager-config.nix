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
    initExtra = ''
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
    ".config/nvim"    = { source = ../files/nvim; };
    ".config/waybar"  = { source = ../files/waybar; };
  };
}

