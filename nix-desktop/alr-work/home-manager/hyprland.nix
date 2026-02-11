{ config, pkgs, inputs, ... }:

{

  imports = [
    ./waybar.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null; # Use the version from the system module
    portalPackage = null;
    
    settings = {
      "$mod" = "SUPER";
      monitor = ",preferred,auto,1";

      # Autostart
      "exec-once" = [
        "waybar"
        "swww init"
      ];

      input = {
        kb_layout = "no"; # Norwegian layout
        follow_mouse = 1;
        touchpad.natural_scroll = true;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      };

      bind = [
        "$mod, Q, exec, kitty"
        "$mod, C, killactive,"
        "$mod, M, exit,"
        "$mod, R, exec, wofi --show drun"
        "$mod, V, togglefloating,"
        
        # Focus with arrows
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Switch workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
      ];
    };
  };

  # Packages needed for this specific desktop
  home.packages = with pkgs; [
    kitty
    wofi
    swww
    pavucontrol # Audio control
  ];
}
