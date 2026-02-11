{ config, pkgs, inputs, ... }:

{

  imports = [
    ./waybar.nix
    ./hyprlock.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = null;
    
    settings = {
      "$mod" = "SUPER";
      

	monitor = [

	# name, resolution@refresh, position, scale
    
    	# 1. Main Monitor (Samsung Ultrawide)
    	# Positioned at 0x0
    	"DP-7, 3440x1440@99.98, 0x0, 1"

    	# 2. Laptop Monitor (BOE)
    	# Positioned at 3440x0 (to the right of the Ultrawide)
    	"eDP-1, 1920x1200@60.00, 3440x0, 1"

	];

	workspace = [

    	"1, monitor:DP-7"
    	"2, monitor:DP-7"
    	"3, monitor:DP-7"
	"4, monitor:DP-7"
	"5, monitor:DP-7"
    	"10, monitor:eDP-1" # Keep workspace 10 on the laptop
  ];

      # Autostart
      "exec-once" = [
        #"waybar"
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
	"$mod, T, exec, ghostty"
        "$mod, C, killactive,"
	"$mod, L, exec, hyprlock"
        "$mod, M, exit,"
        "$mod, SPACE, exec, wofi --show drun"
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
	"$mod, 4, workspace, 4"
	"$mod, 5, workspace, 5"
	"$mod, 6, workspace, 6"
      ];
    };
  };

  # Packages needed for this specific desktop
  home.packages = with pkgs; [
    ghostty
    wofi
    swww
    pavucontrol # Audio control
  ];


}
