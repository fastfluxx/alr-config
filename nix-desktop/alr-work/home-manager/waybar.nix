{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "tray" ];

        "clock" = { format = "{:%H:%M}  "; };
        "pulseaudio" = { format = "{volume}% {icon}"; };
      };
    };
    style = ''
      window#waybar { background: rgba(30, 30, 46, 0.8); color: #cdd6f4; }
      #workspaces button { padding: 0 10px; color: #cdd6f4; }
      #workspaces button.active { color: #89b4fa; border-bottom: 2px solid #89b4fa; }
    '';
  };
}
