
{ pkgs, ... }:

{
  imports =
    [
      ./hosts.nix
      ../../common/nixos/nix.nix
      ../../common/nixos/base.nix
      ../../common/nixos/desktop.nix
      ../../common/nixos/sddm-greeter.nix
      ../../common/nixos/sddm-hyprlock.nix
    ];

  networking.hostName = "alr-workstation";
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

  # The laptop panel reads as connected even with the lid shut, so keep the
  # greeter on the ultrawide; see common/nixos/sddm-greeter.nix.
  local.sddmGreeter = {
    enable = true;
    primaryOutput = "DP-7";
    otherOutputs = [ "eDP-1" "DP-5" ];
  };

  security.pam.services.hyprlock = {};

  boot.initrd = {
    systemd.enable = true;          # Switches NixOS to modern systemd stage-1 boot
    luks.fido2Support = false;      # Must be false! Systemd handles this natively now

    luks.devices = {
      "crypted" = {
        device = "/dev/disk/by-uuid/949ff513-958e-410c-afdb-3d3b25347d70";
        crypttabExtraOpts = [ "fido2-device=auto" ];
      };
    };
  };

  # EFI systemd bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [
    "video=DP-7:e"
  ];

  # Nix-ld to make the linker work for self compile binaries
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
      icu
      libunwind
      libuuid
    ];
  };

  services.pipewire.wireplumber.extraConfig = {
    "monitor.bluez.properties" = {
      "bluez5.codecs" = [ "sbc" "sbc_xq" "aac" "aptx" "aptx_hd" ];
    };
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
  services.blueman.enable = true;

  # Docking Requirements
  services.udev.packages = [ pkgs.bolt ];
  services.hardware.bolt.enable = true;

  networking.firewall.allowedUDPPorts = [ 5514 ];

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
    virtiofsd             # Tool for sharing directoies from host to VM
    pulseaudio            # For audio control
  ];


  # COSMIC GDM

  ## COSMIC Login manager
  #services.displayManager.cosmic-greeter.enable = true;
  ## COSMIC GDM
  #services.desktopManager.cosmic.enable = true;

  # Gnome Failover
  #services.displayManager.gdm.enable = true;
  #services.desktopManager.gnome.enable = true;

  #services.syncthing = {
  #enable = true;
  #dataDir = "/home/alr/syncthing";
  #user = "alr";
  #};

}
