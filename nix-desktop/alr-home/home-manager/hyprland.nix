{ lib, ... }:

{

  imports = [
    ../../common/home-manager/hyprland.nix
    ../../common/home-manager/waybar.nix
    ../../common/home-manager/hyprlock.nix
    ../../common/home-manager/hypridle.nix
    ../../common/home-manager/ghostty.nix
  ];

  # hyprlock was commented out of this host's imports, so locking has never
  # actually worked here. Set local.hyprlock.enable = true to turn it on;
  # hypridle then grows a lock listener and Hyprland a $mod+L bind.
  local.hyprlock.enable = false;
  local.hypridle.enable = true;

  local.waybar.modulesRight = [ "tray" "pulseaudio" "bluetooth" "network" "cpu" "memory" "battery" ];

  local.hyprland = {
    enable = true;
    wallpaper = ../../wallpaper/Fantasy-Autumn.png;

    monitors = [
      # 1. Main Monitor (Samsung Ultrawide)
      { output = "DP-4"; mode = "3440x1440@99.98"; position = "0x0"; scale = 1; }

      # 2. Laptop Monitor (BOE), to the right of the Ultrawide. lidOutput
      #    below disables and restores it as the lid closes and opens.
      { output = "eDP-1"; mode = "1920x1200@60.00"; position = "3440x0"; scale = 1; }
    ];

    lidOutput = "eDP-1";

    workspaceMonitors =
      lib.genAttrs (map toString (lib.range 1 9)) (_: "DP-4")
      // {
        "10" = "eDP-1"; # Keep workspace 10 on the laptop
      };
  };

}
