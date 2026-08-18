{ lib, pkgs, ... }:

{

  imports = [
    ../../common/home-manager/hyprland.nix
    ../../common/home-manager/waybar.nix
    ../../common/home-manager/hyprlock.nix
    ../../common/home-manager/hypridle.nix
    ../../common/home-manager/ghostty.nix
  ];

  # No lock screen on this host.
  local.hyprlock.enable = false;

  local.hypridle = {
    enable = true;
    dpmsTimeout = 500;
  };

  local.hyprland = {
    enable = true;
    wallpaper = ../../wallpaper/Fantasy-Autumn.png;

    monitors = [
      # Fallback: auto-configure any connected monitor
      { output = ""; mode = "preferred"; position = "auto"; scale = 1; }

      # Uncomment and adjust for your specific setup:
      # { output = "DP-3"; mode = "3440x1440@99.98"; position = "0x0"; scale = 1; }
      # { output = "eDP-1"; mode = "1920x1200@60.00"; position = "3440x0"; scale = 1; }
    ];

    # No workspace pinning while `monitors` is the catch-all above: the rules
    # used to name DP-3, which is not a connector this host configures. Set both
    # together once the real connector name is known.
    workspaceMonitors = { };
  };

  # Packages needed for this specific desktop
  home.packages = with pkgs; [
    blueman # Bluetooth manager (used by waybar bluetooth module)
  ];

}
