# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
#  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.devices = [ "nodev" ];
  
  nix = {
    # use the unstable Nix package which includes flakes support
    package = pkgs.nixVersions.latest;

    # pass through the experimental‐features flags into /etc/nix/nix.conf
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
    gsp.enable = true;
  };

  hardware.graphics = {
    enable = true;
  };

  services.xserver = {
    enable = true;
    videoDrivers = ["nvidia"];
  };

  # Gaming 
  programs.steam.enable = true;
  hardware.xone.enable = true;


  # Hyprland Window Manager
  programs.hyprland = {
    enable    = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];


  # Force all apps (X11, XWayland, Wayland) to pick it up:
  environment.variables = {
    XCURSOR_THEME = "Vanilla-DMZ";
    # optionally tweak size if you like:
    XCURSOR_SIZE  = "200";
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true; 
  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the GNOME Desktop Environment. <------ disabling for hyprland
  services.xserver.displayManager.gdm.enable = false;
  services.xserver.desktopManager.gnome.enable = false;

  services.displayManager.sddm = {
    enable        = true;
    package       = pkgs.kdePackages.sddm;
    theme         = "catppuccin-macchiato";
    wayland.enable = true;
  };

  services.displayManager.defaultSession = "hyprland";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.logonix = {
    isNormalUser = true;
    description = "david";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Disable apps like firefox.
  programs.firefox.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    flatpak
    discord
    neovim
    ghostty
    zsh
    git
    gcc               # C compiler
    tree-sitter       # neovim tree plugin installer
    wl-clipboard      # Wayland/Hyperland clipboard
    fzf               # Fuzzyfinder
    zoxide            # .zshrc file finder
    vulkan-loader
    vulkan-tools
    vulkan-validation-layers
    steam
    linuxKernel.packages.linux_zen.xone              # Xbox Usb Dongle
    swww
    waybar
    rofi-wayland # 2
    libnotify # 1
    mako
    networkmanagerapplet 
    wlr-randr# Screen Size  
    psmisc   # Killall
    jq       # JSON parser
    bc       # for arithmetic
    gawk     # sometimes used in the script
    nautilus
    pavucontrol
    rofi-pulse-select
    # <-----------------------| Worked up to here
    vanilla-dmz
    playerctl
    wlogout
    (catppuccin-sddm.override {flavor = "macchiato"; })
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
  ];


  # Default Terminal and Shells
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;


  # Optionally, enable Flatpack system helper service
  services.flatpak.enable = true; 

  services.udev.extraRules = ''
    # Enable wakeup for keyboard (phaseone)
    SUBSYSTEM=="usb", ATTRS{product}=="phaseone", ATTR{power/wakeup}="enabled"


    # Disable wakeup for Xbox controller dongle
    SUBSYSTEM=="usb", ATTRS{product}=="XBOX ACC", ATTR{power/wakeup}="disabled"
  '';

  systemd.services.enable-xhc0-wakeup = {
    description = "Enable XHC0 ACPI Wakeup";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/bin/sh -c 'echo XHC0 > /proc/acpi/wakeup'";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
