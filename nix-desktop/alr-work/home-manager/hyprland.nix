{ lib, ... }:

let
  hypr = import ../../common/lib/hypr.nix { inherit lib; };
  inherit (hypr) bindOpts exec;
in
{

  imports = [
    ../../common/home-manager/hyprland.nix
    ../../common/home-manager/waybar.nix
    ../../common/home-manager/hyprlock.nix
    ../../common/home-manager/hypridle.nix
    ../../common/home-manager/ghostty.nix
  ];

  local.hyprlock.enable = true;
  local.hypridle.enable = true;

  local.hyprland = {
    enable = true;
    wallpaper = ../../wallpaper/Fantasy-Autumn.png;

    monitors = [
      # 1. Main Monitor (Samsung Ultrawide)
      { output = "DP-7"; mode = "3440x1440@99.98"; position = "0x0"; scale = 1; }

      # 2. New Side Monitor (BenQ), directly to the right of the Ultrawide
      { output = "DP-5"; mode = "1920x1080@60.00"; position = "3440x0"; scale = 1; }

      # 3. Laptop Monitor (BOE), disabled because the lid is closed
      { output = "eDP-1"; disabled = true; }
    ];

    workspaceMonitors =
      lib.genAttrs (map toString (lib.range 1 8)) (_: "DP-7")
      // {
        "9" = "DP-5";
        "10" = "eDP-1"; # Keep workspace 10 on the laptop
      };

    extraBinds = [
      # Lid Switch Actions (was `bindl`, hence locked = true)
      (bindOpts "switch:on:Lid Switch"
        (exec ''hyprctl keyword monitor "eDP-1, disable"'')
        "{ locked = true }")
      (bindOpts "switch:off:Lid Switch"
        (exec ''hyprctl keyword monitor "eDP-1, 1920x1200@60.00, 3440x0, 1"'')
        "{ locked = true }")
    ];
  };

}
