
{ config, pkgs, ... }:

{
  imports =
    [
      ./hosts.nix
    ];




  # EFI systemd bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  ## Enable flakes
  nix.settings.experimental-features = "nix-command flakes";


  # COSMIC GDM

  ## COSMIC Login manager
  services.displayManager.cosmic-greeter.enable = true;
  ## COSMIC GDM
  services.desktopManager.cosmic.enable = true;

  # Gnome Failover
  #services.displayManager.gdm.enable = true;
  #services.desktopManager.gnome.enable = true;


  # Docking Requirements
  hardware.enableRedistributableFirmware = true;
  services.udev.packages = [ pkgs.bolt ];
  services.hardware.bolt.enable = true;


  networking.hostName = "alr-work"; # Define your hostname.


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
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" ];
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
