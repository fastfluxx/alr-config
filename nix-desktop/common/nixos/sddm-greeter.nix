# Which head the SDDM greeter lands on.
#
# The greeter runs in its own Weston session, which knows nothing about the
# Hyprland layout. Weston enables every connected head and Qt treats the first
# wl_output it is offered as the greeter's primary screen -- on a docked laptop
# that is the internal panel, which may well be behind a closed lid, leaving
# the password box on a display nobody can see. Weston has no "preferred
# output" key, so the heads are picked when the greeter starts: while the
# primary monitor is connected the rest are switched off, and undocked the
# stock config is used so the panel still gets a login box.
{ config, lib, pkgs, ... }:

let
  cfg = config.local.sddmGreeter;

  westonBase = ''
    [libinput]
    enable-tap=${lib.boolToString config.services.libinput.mouse.tapping}
    left-handed=${lib.boolToString config.services.libinput.mouse.leftHanded}

    [keyboard]
    keymap_model=${config.services.xserver.xkb.model}
    keymap_layout=${config.services.xserver.xkb.layout}
    keymap_variant=${config.services.xserver.xkb.variant}
    keymap_options=${config.services.xserver.xkb.options}
  '';

  outputOff = output: ''
    [output]
    name=${output}
    mode=off
  '';

  westonDocked = pkgs.writeText "weston-${cfg.primaryOutput}.ini"
    (lib.concatStringsSep "\n" ([ westonBase ] ++ map outputOff cfg.otherOutputs));

  westonUndocked = pkgs.writeText "weston-all-heads.ini" westonBase;

  # Mirrors the upstream compositorCmds.weston, minus the choice of ini file.
  compositor = pkgs.writeShellScript "sddm-weston" ''
    ini=${westonUndocked}
    if ${pkgs.gnugrep}/bin/grep -qx connected /sys/class/drm/*-${cfg.primaryOutput}/status 2>/dev/null; then
      ini=${westonDocked}
    fi
    exec ${lib.getExe pkgs.weston} --shell=kiosk -c "$ini"
  '';
in
{
  options.local.sddmGreeter = {
    enable = lib.mkEnableOption "pinning the SDDM greeter to one monitor";

    primaryOutput = lib.mkOption {
      type = lib.types.str;
      example = "DP-7";
      description = ''
        Connector the greeter should appear on. When it is disconnected the
        greeter falls back to every connected head, so an undocked laptop still
        gets a login box on its own panel.
      '';
    };

    otherOutputs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "eDP-1" "DP-5" ];
      description = ''
        Connectors to switch off in the greeter while primaryOutput is
        connected. Anything left out here can still end up holding the login
        box, since Weston enumerates heads in connector order.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm.wayland.compositorCommand = toString compositor;
  };
}
