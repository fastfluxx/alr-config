
{ config, pkgs, inputs, ... }:

{
  imports =
    [
      #./hosts.nix
    ];


    # Steam

    programs.steam = {
        enable = true;
        #remotePlay.openFirewall = true; # Optional
        #dedicatedServer.openFirewall = true; # Optional
    };

    # Crucial for DirectX and Vulkan translation
    hardware.graphics.enable32Bit = true;

    programs.hyprland = {
        enable = true;
        # Using the flake input for the latest features
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    };

    hardware.graphics = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;  # For 32-bit apps / Steam
    };

    hardware.nvidia = {
        modesetting.enable = true;        # Required for Hyprland/Wayland
        powerManagement.enable = false;   # Set true if you have sleep/suspend issues
        open = false;                     # Use proprietary driver (better for GTX 1080)
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
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
  ];

  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

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
        LIBVA_DRIVER_NAME = "nvidia";
        XDG_SESSION_TYPE = "wayland";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        WLR_NO_HARDWARE_CURSORS = "1";  # Fixes invisible cursor on Nvidia
        NIXOS_OZONE_WL = "1";
    };



  hardware.enableRedistributableFirmware = true;




  networking.hostName = "alr-game";


  # Enable networking
  networking.networkmanager.enable = true;

  networking.nameservers = [ "1.1.1.1" ];


  networking.firewall.enalbe = true;


  # --- Air-Gap Specialisation ---
  specialisation.airgap.configuration = {
    system.nixos.tags = [ "air-gapped" ];


  networking.firewall = {
      # 1. Block everything by default
      extraCommands = ''
        # Flush existing custom chains
        iptables -F OUTPUT
        
        # Set default policy to DROP for outgoing
        iptables -P OUTPUT DROP

        # Allow Loopback (Internal system comms)
        iptables -A OUTPUT -o lo -j ACCEPT

        # Allow Local LAN Traffic (Edit these ranges as needed)
        iptables -A OUTPUT -d 192.168.15.0/24 -j ACCEPT
        
        # Allow Multicast/mDNS (Optional: for .local addresses)
        iptables -A OUTPUT -d 224.0.0.0/4 -j ACCEPT
      '';

      # Ensure we clean up when switching back
      extraStopCommands = ''
        iptables -P OUTPUT ACCEPT
      '';
    };

    };
  


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
  pulseaudio      # For audio control
  networkmanagerapplet # Wi-Fi tray icon
  brightnessctl   # Control screen brightness (Laptop)
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
