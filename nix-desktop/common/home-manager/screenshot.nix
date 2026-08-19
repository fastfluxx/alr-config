# Screenshots. grim captures, slurp draws the selection box, wl-copy puts the
# PNG on the clipboard. Every mode writes a file *and* copies, because a
# clipboard offer on Wayland dies with the process that owns it -- wl-copy
# forks and survives, but a logout still loses the shot, so the file is the
# copy of record.
#
# Deliberately not grimblast or hyprshot: grimblast calls
# `hyprctl keyword layerrule ...` to suppress the selection layer's animation,
# and Hyprland 0.56 answers that with `unknown request` (hyprlang, and with it
# `hyprctl keyword`, is gone). Nothing here depends on a dropped API.
{ config, lib, pkgs, ... }:

let
  cfg = config.local.screenshot;

  hypr = import ../lib/hypr.nix { inherit lib; };
  inherit (hypr) bind exec;

  mod = config.local.hyprland.modifier;

  # hyprctl ships with the compositor, and the session's own package is the one
  # whose `monitors` / `activewindow` answers match the running instance.
  hyprlandPackage = config.wayland.windowManager.hyprland.package;

  # hyprpicker paints a still copy of the screen over the live one, so hover
  # states and animations cannot shift under the selection box while it is
  # being drawn. grim then captures the frozen overlay, which is the same
  # pixels the selection was made against.
  freeze = lib.optionalString cfg.freeze ''
    if [ "$mode" = region ]; then
      hyprpicker --render-inactive --no-zoom --quiet &
      freeze_pid=$!
      trap 'kill "$freeze_pid" 2>/dev/null || true' EXIT
      sleep 0.2
    fi
  '';

  screenshot = pkgs.writeShellApplication {
    name = "screenshot";

    # writeShellApplication puts these on PATH and runs shellcheck at build
    # time, so a typo here fails `nixos-rebuild` rather than a keypress.
    runtimeInputs = [
      pkgs.grim
      pkgs.slurp
      pkgs.wl-clipboard
      pkgs.jq
      pkgs.libnotify
      hyprlandPackage
    ] ++ lib.optional cfg.freeze pkgs.hyprpicker;

    text = ''
      mode="''${1:-region}"

      case "$mode" in
        region|window|output) ;;
        *)
          echo "usage: screenshot [region|window|output]" >&2
          exit 2
          ;;
      esac

      ${freeze}
      dir=${lib.escapeShellArg cfg.directory}
      mkdir -p "$dir"

      # Two captures inside the same second would otherwise land on the same
      # name and the second would silently overwrite the first.
      stamp=$(date +%Y-%m-%d_%H-%M-%S)
      target="$dir/$stamp.png"
      n=1
      while [ -e "$target" ]; do
        target="$dir/$stamp-$n.png"
        n=$((n + 1))
      done

      case "$mode" in
        region)
          # slurp exits non-zero when the selection is cancelled with Escape.
          # That is a normal way to back out, not a failure worth reporting.
          if ! geometry=$(slurp -d); then
            exit 0
          fi
          grim -g "$geometry" "$target"
          ;;
        window)
          geometry=$(hyprctl activewindow -j |
            jq -er '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
          grim -g "$geometry" "$target"
          ;;
        output)
          # -o takes a connector name, which avoids dividing the monitor's
          # pixel size by its scale to arrive at grim's logical geometry.
          output=$(hyprctl monitors -j | jq -er '.[] | select(.focused) | .name')
          grim -o "$output" "$target"
          ;;
      esac

      wl-copy --type image/png < "$target"

      # Best effort, and silent. mako now owns org.freedesktop.Notifications
      # (common/home-manager/mako.nix), so this normally shows -- but a capture
      # that is already written and copied must not fail or report just because
      # the daemon is down.
      notify-send --app-name=screenshot --icon="$target" \
        "Screenshot saved" "$target" 2>/dev/null || true
    '';
  };
in
{
  options.local.screenshot = {
    enable = lib.mkEnableOption "grim/slurp screenshots, bound under the session modifier and Print";

    directory = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/Pictures/Screenshots";
      defaultText = lib.literalExpression ''"''${config.home.homeDirectory}/Pictures/Screenshots"'';
      description = "Where captures are written. Created on first use.";
    };

    freeze = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Freeze the screen while a region is being selected. Costs an extra
        package (hyprpicker) and about 200ms before the selection box appears.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ screenshot ];

    # The region grab is the one that gets used, so it sits on a home-row
    # combo rather than on Print; the other two modes stay on Print, which
    # therefore does nothing on its own.
    local.hyprland.extraBinds = [
      (bind "${mod} + SHIFT + S" (exec "${screenshot}/bin/screenshot region"))
      (bind "SHIFT + Print" (exec "${screenshot}/bin/screenshot window"))
      (bind "${mod} + Print" (exec "${screenshot}/bin/screenshot output"))
    ];
  };
}
