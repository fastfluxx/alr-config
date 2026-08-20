
{ config, pkgs, ... }:

{
  imports =
    [
      ../../common/nixos/nix.nix
      ../../common/nixos/base.nix
      ../../common/nixos/desktop.nix
    ];

  networking.hostName = "alr-game";
  system.stateVersion = "23.11"; # Set at first install; see man configuration.nix.

  programs.steam = {
    enable = true;
    #remotePlay.openFirewall = true; # Optional
    #dedicatedServer.openFirewall = true; # Optional
  };

  hardware.graphics.enable32Bit = true; # For 32-bit apps / Steam

  services.xserver.videoDrivers = [ "nvidia" ];

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

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # WLR_NO_HARDWARE_CURSORS / HYPRLAND_NO_HARDWARE_CURSORS were dropped:
    # neither string appears in the Hyprland 0.56 binary. If the cursor goes
    # missing on Nvidia again, it is a cursor setting in hl.config() now.
  };

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

  networking.firewall.enable = true;

  #services.openssh.enable = true;

}
