
{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hosts.nix
    ];

    programs.hyprland = {
        enable = true;
        # Using the flake input for the latest features
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };

    hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
            intel-media-driver # Optimized for your Intel Ultra 7 (Meteor Lake)
            intel-vaapi-driver
            libvdpau-va-gl
        ];
    };

    services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
    };


    # Add PipeWire for audio
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

  # Add polkit for authentication
  security.polkit.enable = true;

  # EFI systemd bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  ## Enable flakes
  nix.settings.experimental-features = "nix-command flakes";


    fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
    ];

    environment.sessionVariables = {
        # Hint Electron apps (Discord, VS Code, etc.) to use Wayland
        NIXOS_OZONE_WL = "1";
        # Force Intel drivers for hardware acceleration
        LIBVA_DRIVER_NAME = "iHD";
    };


    environment.systemPackages = with pkgs; [
        pulseaudio      # For audio control
        networkmanagerapplet # Wi-Fi tray icon
        brightnessctl   # Control screen brightness (Laptop)
    ];


  # COSMIC GDM

  ## COSMIC Login manager
  #services.displayManager.cosmic-greeter.enable = true;
  ## COSMIC GDM
  #services.desktopManager.cosmic.enable = true;

  # Gnome Failover
  #services.displayManager.gdm.enable = true;
  #services.desktopManager.gnome.enable = true;


  # Docking Requirements
  hardware.enableRedistributableFirmware = true;
  services.udev.packages = [ pkgs.bolt ];
  services.hardware.bolt.enable = true;


  networking.hostName = "alr-workstation"; # Define your hostname.


  # Enable networking
  networking.networkmanager.enable = true;

  networking.nameservers = [ "1.1.1.1" ];


  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  # Set your time zone.
  time.timeZone = "Europe/Oslo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "no";
    xkb.variant = "";
  };


  services.syncthing = {
  enable = true;
  dataDir = "/home/alr/syncthing";
  user = "alr";
  };


  # Enable virtualization (KVM/QEMU)
  virtualisation.libvirtd.enable = true;


  # Enable virtualization (Docker)
  virtualisation.docker = {
    enable = true;

  };


  # Configure console keymap
  console.keyMap = "no";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alr = {
    isNormalUser = true;
    description = "alr";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" "docker" "video" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
  git
  vim
  iptables
  ebtables
  dnsmasq
  wireguard-tools
  ];




  programs.zsh.enable = true;

  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
