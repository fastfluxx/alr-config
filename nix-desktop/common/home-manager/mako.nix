# Notification daemon.
#
# Nothing owned org.freedesktop.Notifications before this, so every
# notify-send on these machines failed with ServiceUnknown -- including the
# "Screenshot saved" confirmation, which is written to swallow the error.
#
# home-manager's services.mako module installs the package and the D-Bus
# activation file but no systemd unit, and it does not link the one mako ships
# either. The unit below is mako's own, with WantedBy pointed at
# hyprland-session.target so it starts with the session the way waybar does,
# rather than waiting to be D-Bus activated by the first notification.
{ config, lib, pkgs, ... }:

let
  cfg = config.local.mako;
  mako = config.services.mako.package;

  # Catppuccin Mocha, matching waybar and ghostty.
  base = "#1e1e2e";
  text = "#cdd6f4";
  blue = "#89b4fa";
  red = "#f38ba8";
in
{
  options.local.mako.enable = lib.mkEnableOption "the mako notification daemon";

  config = lib.mkIf cfg.enable {
    services.mako = {
      enable = true;

      settings = {
        font = "JetBrainsMono Nerd Font 11";
        # The trailing pair of hex digits is alpha; mako takes #rrggbbaa.
        background-color = "${base}f0";
        text-color = text;
        border-color = blue;
        border-size = 2;
        border-radius = 10;
        padding = 12;
        margin = 12;
        width = 380;
        default-timeout = 5000;
        anchor = "top-right";
        layer = "overlay";

        # Critical notifications stay until dismissed. A timeout of 0 is the
        # only way to say "no timeout"; leaving the key out inherits 5s above.
        "urgency=critical" = {
          border-color = red;
          default-timeout = 0;
        };
      };
    };

    systemd.user.services.mako = {
      Unit = {
        Description = "Lightweight Wayland notification daemon";
        Documentation = "man:mako(1)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        ExecCondition = ''${pkgs.runtimeShell} -c '[ -n "$WAYLAND_DISPLAY" ]' '';
        ExecStart = "${mako}/bin/mako";
        ExecReload = "${mako}/bin/makoctl reload";
        Restart = "on-failure";
      };

      Install.WantedBy = [ "hyprland-session.target" ];
    };
  };
}
