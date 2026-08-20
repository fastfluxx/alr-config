
{ pkgs, ... }:

{
  imports =
    [
      ../../common/nixos/nix.nix
      ../../common/nixos/base.nix
      ../../common/nixos/desktop.nix
      ../../common/nixos/sddm-greeter.nix
      ../../common/nixos/sddm-hyprlock.nix
    ];

  networking.hostName = "alr-home";
  system.stateVersion = "23.11"; # Set at first install; see man configuration.nix.

  # Intel Ultra 7 (Meteor Lake).
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-vaapi-driver
    libvdpau-va-gl
  ];

  environment.sessionVariables = {
    # Force Intel drivers for hardware acceleration
    LIBVA_DRIVER_NAME = "iHD";
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

  security.pam.services.hyprlock = {};

  # EFI systemd bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
  services.blueman.enable = true;

  # Docking Requirements
  services.udev.packages = [ pkgs.bolt ];
  services.hardware.bolt.enable = true;

  # Enable virtualization (KVM/QEMU and Docker)
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  users.users.alr.extraGroups = [ "libvirtd" "kvm" "docker" ];

  environment.systemPackages = with pkgs; [
    networkmanagerapplet  # Wi-Fi tray icon and nm-connection-editor
    brightnessctl         # Backlight control; this host has a panel
    iptables
    ebtables
    dnsmasq
    wireguard-tools
    pulseaudio      # For audio control
  ];

}
