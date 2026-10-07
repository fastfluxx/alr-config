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

    # This host docks in two places and the two docks present different MST
    # topologies, so the ultrawide lands on a different connector at each. Both
    # entries are listed; whichever connector is absent is simply not matched.
    #
    #   office (ThinkPad USB-C dock):  DP-7 Samsung S34C65xT + DP-5 BenQ
    #   home   (ThinkPad TBT3 dock):   DP-6 Samsung C34J79x  (no side monitor)
    monitors = [
      # 1a. Main Monitor at the office (Samsung S34C65xT ultrawide)
      { output = "DP-7"; mode = "3440x1440@99.98"; position = "0x0"; scale = 1; }

      # 1b. Main Monitor at home (Samsung C34J79x ultrawide)
      { output = "DP-6"; mode = "3440x1440@100.00"; position = "0x0"; scale = 1; }

      # 2. Side Monitor (BenQ), directly to the right of the Ultrawide.
      #    Office only -- DP-5 enumerates at home but nothing is plugged into it.
      { output = "DP-5"; mode = "1920x1080@60.00"; position = "3440x0"; scale = 1; }

      # 3. Laptop Monitor (BOE). "auto" puts it right of whatever is actually
      #    present -- right of the BenQ at the office, right of the ultrawide at
      #    home -- so there is no dead gap in the layout at either desk.
      #    lidOutput below disables and restores it as the lid closes and opens.
      { output = "eDP-1"; mode = "1920x1200@60.00"; position = "auto"; scale = 1; }
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
