{ pkgs, ... }:

{
  programs.waybar = {

    enable = true;


    systemd = {
        enable = true;
        targets = [ "hyprland-session.target" ];
    };

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        margin-top = 5;
        margin-left = 10;
        margin-right = 10;
        spacing = 4;

        modules-left = [ "hyprland/workspaces" "hyprland/submap" ];
        modules-center = [ "clock" "hyprland/window" ];
        modules-right = [ "pulseaudio" "bluetooth" "network" "cpu" "memory" "battery" "tray" ];

        "hyprland/workspaces" = {
          on-click = "activate";
          format = "{icon}";
          format-icons = {
            "1" = "󰨇";
            "2" = "󰨇";
            "3" = "󰨇";
            "4" = "󰨇";
            "5" = "󰨇";
            "6" = "󰨇";
            "7" = "󰨇";
            "8" = "󰨇";
            "9" = "󰨇";
            urgent = "";
            active = "󱎴";
            default = "";
          };
        };

        "hyprland/window" = {
          format = "{}";
          max-length = 50;
          separate-outputs = true;
        };

        "clock" = {
          format = "  {:%Y-%m-%d   %H:%M} ";
          format-alt = "{:%A, %B %d, %Y (%R)} ";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };

        "cpu" = {
          format = "[   {usage}% ]";
          tooltip = false;
        };

        "memory" = {
          format = "[   {used} / {total}]";
        };

	"battery" = {
  	states = {
	    	warning = 30;
    		critical = 15;
  	};
	  format = " [{icon} {capacity}%]    ";
	  format-charging = "{capacity}%  ";
	  format-plugged = " [     {capacity}% ]    ";
	  format-alt = "{time} {icon}";
	  # Icons change based on charge level
	  format-icons = ["" "" "" "" ""];
	};

	"bluetooth" = {
  		format = "[  {status} ]";
	  	format-connected = "[  {device_alias} ]";
  		format-connected-battery = "[  {device_alias} {device_battery_percentage}% ]";
  		# format-device-preference = [ "device1", "device2" ]; # preference list deciding the displayed device
  		tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
  		tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
  		tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
  		tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
  
  		# Left click opens the GUI manager
  		on-click = "${pkgs.blueman}/bin/blueman-manager";
  
  		# Right click toggles bluetooth power
  		on-click-right = "rfkill toggle bluetooth";
	};

        "pulseaudio" = {
          format = "[ {icon}  {volume}% ]";
          format-bluetooth = "[ {volume}% {icon} ]";
          format-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" ];
          };
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        };

        "network" = {
          format-wifi = "[   {essid} : {ipaddr} ]";
          format-ethernet = "[ 󰈀 {ipaddr} / {cidr} ]";
          format-disconnected = "[ 󰌙 Network Disconnected ]";
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", Roboto, Helvetica, Arial, sans-serif;
        font-size: 14px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(21, 18, 27, 0.7);
        color: #cdd6f4;
        transition-property: background-color;
        transition-duration: .5s;
        border-radius: 10px;
      }

      #workspaces button {
        padding: 0 5px;
        color: #cdd6f4;
      }

      #workspaces button.active {
        color: #b4befe;
        font-weight: bold;
      }

      #workspaces button.urgent {
        color: #f38ba8;
      }

      #modules-right {
        margin-right: 10px;
      }

      #clock, #cpu, #memory, #pulseaudio, #network, #tray {
        padding: 0 10px;
        margin: 4px 0;
      }

      #clock {
        color: #fab387;
	font-size: 16px;
      }

      #pulseaudio {
        color: #89b4fa;
      }

	#bluetooth {
  		color: #89b4fa;
  		padding: 0 10px;
	}

	#bluetooth.connected {
  		color: #a6e3a1;
	}

	#bluetooth.disabled {
  		color: #f38ba8;
	}

      #network {
        color: #a6e3a1;
      }
    '';
  };
}
