
{ config, pkgs, inputs, ... }:

{
  imports =
    [
      #./hosts.nix
      ../../common/nixos/nix.nix
    ];


    # Steam

    programs.steam = {
        enable = true;
        #remotePlay.openFirewall = true; # Optional
        #dedicatedServer.openFirewall = true; # Optional
    };


    programs.hyprland = {
        enable = true;
        # Using the flake input for the latest features
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    };

    hardware.graphics = {
        enable = true;
        enable32Bit = true;
        #driSupport = true;
        #driSupport32Bit = true;  # For 32-bit apps / Steam
    };



    hardware.nvidia = {
        modesetting.enable = true;
        open = false; # Absolutely keep this false; open kernel modules do not support Pascal!

        # Manually construct the 580 legacy driver with explicit hashes.
        # This card is a GTX 1080 (Pascal), and 580 is the last branch
        # NVIDIA supports it on -- so the pin is the hardware talking, not
        # inertia. 580.95.05 specifically is the build this host is known
        # good on; do not move it to `production`, and do not swap it for
        # `nvidiaPackages.legacy_580` (580.178.04) without testing on the
        # machine, since that is a different build of the same branch.
        package = config.boot.kernelPackages.nvidiaPackages.production.overrideAttrs {
            version = "580.95.05";
            src = pkgs.fetchurl {
                url = "https://us.download.nvidia.com/XFree86/Linux-x86_64/580.95.05/NVIDIA-Linux-x86_64-580.95.05.run";
                sha256 = "sha256-hJ7w746EK5gGss3p8RwTA9VPGpp2lGfk5dlhsv4Rgqc=";
            };
        };
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


  # Add polkit for authentication
  security.polkit.enable = true;

  # Kernel Parameters

  boot.kernelParams = [
    "nvidia-drm.modeset=1"    # Required for Wayland
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"  # Better suspend support
    "nvidia.NVreg_UsePageAttributeTable=1"
    "usbcore.autosuspend=-1"
    "split_lock_detect=warn"
  ];

  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.initrd.kernelModules = [ "usbhid" "hid_generic" "ohci_pci" "ehci_pci" "xhci_pci" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/ata-Samsung_SSD_750_EVO_500GB_S36SNWBH713688A";
  boot.loader.grub.useOSProber = true;



    fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
    ];

    environment.sessionVariables = {
        # Hint Electron apps (Discord, VS Code, etc.) to use Wayland
        LIBVA_DRIVER_NAME = "nvidia";
        XDG_SESSION_TYPE = "wayland";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        # WLR_NO_HARDWARE_CURSORS / HYPRLAND_NO_HARDWARE_CURSORS were dropped:
        # neither string appears in the Hyprland 0.56 binary. If the cursor goes
        # missing on Nvidia again, it is a cursor setting in hl.config() now.
        NIXOS_OZONE_WL = "1";
    };



  hardware.enableRedistributableFirmware = true;




  networking.hostName = "alr-game";


  # Enable networking
  networking.networkmanager.enable = true;

  networking.nameservers = [ "1.1.1.1" ];


  networking.firewall.enable = true;


  # Set your time zone.
  time.timeZone = "Europe/Oslo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "no";
    xkb.variant = "";
  };

  # Enable Nvidia GPU support
  services.xserver.videoDrivers = [ "nvidia" ];

  # Configure console keymap
  console.keyMap = "no";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alr = {
    isNormalUser = true;
    description = "alr";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
  git
  vim
  networkmanagerapplet # Wi-Fi tray icon
  brightnessctl   # Control screen brightness (Laptop)
  ];

  #services.openssh.enable = true;

  # Enable the background daemon and open the necessary ports
  services.unifi = {
    enable = true;
  #  openFirewall = true;

    unifiPackage = pkgs.unifi;
    mongodbPackage = pkgs.mongodb-7_0;
  };



  programs.zsh.enable = true;

  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
