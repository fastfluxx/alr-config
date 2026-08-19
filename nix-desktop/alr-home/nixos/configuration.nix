
{ config, pkgs, inputs, ... }:

{
  imports =
    [
      #./hosts.nix
      ../../common/nixos/nix.nix
      ../../common/nixos/sddm-greeter.nix
      ../../common/nixos/sddm-hyprlock.nix
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

    # Greeter styled after the lock screen; see common/nixos/sddm-hyprlock.nix.
    local.sddmTheme.enable = true;

    # The theme has no session picker, so name the session rather than leaving
    # it to whatever SDDM happens to have recorded. Note that a remembered
    # session in /var/lib/sddm/state.conf still takes precedence over this --
    # it only decides what runs when there is nothing remembered.
    services.displayManager.defaultSession = "hyprland";

    # Weston hands the greeter to the laptop panel otherwise, since it is
    # enumerated before the ultrawide; see common/nixos/sddm-greeter.nix.
    local.sddmGreeter = {
        enable = true;
        primaryOutput = "DP-4";
        otherOutputs = [ "eDP-1" ];
    };

    services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
    };


    # Add PipeWire for audio
    security.rtkit.enable = true;

    security.pam.services.hyprlock = {};

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    services.blueman.enable = true;

  # Add polkit for authentication
  security.polkit.enable = true;

  # Kernel Parameters

  boot.kernelParams = [
  #"video=DP-7:e"
  ];

  # EFI systemd bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


    fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
    ];

    environment.sessionVariables = {
        # Hint Electron apps (Discord, VS Code, etc.) to use Wayland
        NIXOS_OZONE_WL = "1";
        # Force Intel drivers for hardware acceleration
        LIBVA_DRIVER_NAME = "iHD";
    };




  # Gnome Failover
  #services.displayManager.gdm.enable = true;
  #services.desktopManager.gnome.enable = true;


  # Docking Requirements
  hardware.enableRedistributableFirmware = true;
  services.udev.packages = [ pkgs.bolt ];
  services.hardware.bolt.enable = true;


  networking.hostName = "alr-home"; # Define your hostname.


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
  pulseaudio      # For audio control
  networkmanagerapplet # Wi-Fi tray icon
  brightnessctl   # Control screen brightness (Laptop)
  ];



  # Enable the background daemon and open the necessary ports
  #services.unifi = {
  #  enable = true;
  #  openFirewall = true;

  #  unifiPackage = pkgs.unifi;
  #  mongodbPackage = pkgs.mongodb-7_0;
  #};


  programs.zsh.enable = true;

  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
