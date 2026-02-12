{ config, pkgs, inputs, ... }:

{

  imports = [
    ./waybar.nix
    ./hyprlock.nix
  ];


  home.file."wallpapers/Fantasy-Autumn.png".source = ../../wallpaper/Fantasy-Autumn.png;

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = null;
    
    settings = {
      "$mod" = "SUPER";

      env = [
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "XCURSOR_SIZE,24"
      ];
      

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
        "swww-daemon"
	    "sleep 1 && swww img ~/wallpapers/Fantasy-Autumn.png --transition-type fade --transition-duration 2"
        "hyprctl setcursor Bibata-Modern-Classic 24"
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
	    "$mod, F, exec, firefox"
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

	    # Move windows
	    "$mod CONTROL, left,  movewindow, l"
    	"$mod CONTROL, right, movewindow, r"
    	"$mod CONTROL, up,    movewindow, u"
    	"$mod CONTROL, down,  movewindow, d"

	    # Move windows to workspace
	    "$mod SHIFT, 1, movetoworkspace, 1"
    	"$mod SHIFT, 2, movetoworkspace, 2"
    	"$mod SHIFT, 3, movetoworkspace, 3"
    	"$mod SHIFT, 4, movetoworkspace, 4"
    	"$mod SHIFT, 5, movetoworkspace, 5"
    	"$mod SHIFT, 6, movetoworkspace, 6"
    	"$mod SHIFT, 7, movetoworkspace, 7"
    	"$mod SHIFT, 8, movetoworkspace, 8"
    	"$mod SHIFT, 9, movetoworkspace, 9"
    	"$mod SHIFT, 0, movetoworkspace, 10"

      ];
    };
  };

  # Packages needed for this specific desktop
  home.packages = with pkgs; [
    kitty # Kitty for backup
    wofi
    swww
    pavucontrol # Audio control
    hyprpaper
  ];

  home.pointerCursor = {

    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;

  };


  programs.ghostty = {

    enable = true;
    enableZshIntegration = true;

    settings = {

    "theme" = "Catppuccin Mocha";
    "font-family" = "Monaco";
    "font-size" = 16;

    };

  };


  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [
        # Using a path literal (no quotes) makes Nix handle the relative path
        "${../../wallpaper/Fantasy-Autumn.png}"
      ];
      wallpaper = [
        "DP-7,${../../wallpaper/Fantasy-Autumn.png}"
        "eDP-1,${../../wallpaper/Fantasy-Autumn.png}"
      ];
    };
  };


}
