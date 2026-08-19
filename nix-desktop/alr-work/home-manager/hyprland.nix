{ lib, ... }:

{

  imports = [
    ../../common/home-manager/hyprland.nix
    ../../common/home-manager/waybar.nix
    ../../common/home-manager/hyprlock.nix
    ../../common/home-manager/hypridle.nix
    ../../common/home-manager/ghostty.nix
    ../../common/home-manager/screenshot.nix
    ../../common/home-manager/mako.nix
  ];

  local.hyprlock.enable = true;
  local.hypridle.enable = true;
  local.screenshot.enable = true;
  local.mako.enable = true;

  local.hyprland = {
    enable = true;
    wallpaper = ../../wallpaper/Fantasy-Autumn.png;

    monitors = [
      # 1. Main Monitor (Samsung Ultrawide)
      { output = "DP-7"; mode = "3440x1440@99.98"; position = "0x0"; scale = 1; }

      # 2. New Side Monitor (BenQ), directly to the right of the Ultrawide
      { output = "DP-5"; mode = "1920x1080@60.00"; position = "3440x0"; scale = 1; }

      # 3. Laptop Monitor (BOE), to the right of the BenQ. lidOutput below
      #    disables and restores it as the lid closes and opens.
      { output = "eDP-1"; mode = "1920x1200@60.00"; position = "5360x0"; scale = 1; }
    ];

    lidOutput = "eDP-1";

    workspaceMonitors =
      lib.genAttrs (map toString (lib.range 1 8)) (_: "DP-7")
      // {
        "9" = "DP-5";
        "10" = "eDP-1"; # Keep workspace 10 on the laptop
      };
  };

}
