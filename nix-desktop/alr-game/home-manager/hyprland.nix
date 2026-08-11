{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib.generators) mkLuaInline;

  mod = "SUPER";

  # Lua-safe quoted string literal.
  str = builtins.toJSON;

  # hl.bind(keys, dispatcher) / hl.bind(keys, dispatcher, opts)
  # `_args` makes home-manager render an attrset as a multi-argument Lua call,
  # and mkLuaInline emits raw Lua rather than a quoted string.
  bind = keys: dispatcher: { _args = [ keys (mkLuaInline dispatcher) ]; };
  bindOpts = keys: dispatcher: opts: {
    _args = [ keys (mkLuaInline dispatcher) (mkLuaInline opts) ];
  };

  exec = cmd: "hl.dsp.exec_cmd(${str cmd})";

  # Focus/move by direction, on $mod and $mod+CONTROL respectively.
  directionBinds = lib.concatMap (d: [
    (bind "${mod} + ${d}" "hl.dsp.focus({ direction = ${str d} })")
    (bind "${mod} + CONTROL + ${d}" "hl.dsp.window.move({ direction = ${str d} })")
  ]) [ "left" "right" "up" "down" ];

  # Switch to workspace N, and move the active window to workspace N.
  workspaceBinds = lib.concatMap (i: [
    (bind "${mod} + ${toString i}" "hl.dsp.focus({ workspace = ${toString i} })")
    (bind "${mod} + SHIFT + ${toString i}" "hl.dsp.window.move({ workspace = ${toString i} })")
  ]) (lib.range 1 9);

  # Autostart. 0.56 has no exec-once; the equivalent is a hyprland.start handler.
  startupCommands = [
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "swww-daemon"
    "sleep 1 && swww img ~/wallpapers/Fantasy-Autumn.png --transition-type fade --transition-duration 2"
    "hyprctl setcursor Bibata-Modern-Classic 24"
  ];
in
{

  imports = [
    ./waybar.nix
    ./hypridle.nix
  ];


  home.file."wallpapers/Fantasy-Autumn.png".source = ../../wallpaper/Fantasy-Autumn.png;

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = null;

    # Hyprland 0.56 dropped hyprlang; hyprland.conf is no longer read at all.
    configType = "lua";

    settings = {

      env = map (e: { _args = e; }) [
        [ "XCURSOR_THEME" "Bibata-Modern-Classic" ]
        [ "XCURSOR_SIZE" "24" ]
        # Ghostty
        [ "QT_QPA_PLATFORM" "wayland" ]
        [ "GDK_BACKEND" "wayland" ]
        [ "XDG_SESSION_TYPE" "wayland" ]
      ];

      monitor = [

        # Fallback: auto-configure any connected monitor
        { output = ""; mode = "preferred"; position = "auto"; scale = 1; }

        # Uncomment and adjust for your specific setup:
        # { output = "DP-3"; mode = "3440x1440@99.98"; position = "0x0"; scale = 1; }
        # { output = "eDP-1"; mode = "1920x1200@60.00"; position = "3440x0"; scale = 1; }

      ];

      # `workspace` is now `workspace_rule`.
      workspace_rule =
        map (i: { workspace = toString i; monitor = "DP-3"; }) (lib.range 1 9);
        # { workspace = "10"; monitor = "eDP-1"; } # Keep workspace 10 on the laptop

      # Plain settings now live under hl.config().
      config = [{

        input = {
          kb_layout = "no"; # Norwegian layout
          kb_variant = "";
          kb_options = "";
          follow_mouse = 1;
          touchpad.natural_scroll = true;
        };

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          # Gradients are structured now, not a "colA colB Ndeg" string.
          col.active_border = {
            colors = [ "rgba(33ccffee)" "rgba(00ff99ee)" ];
            angle = 45;
          };
        };

      }];

      on = [
        {
          _args = [
            "hyprland.start"
            (mkLuaInline ''
              function()
              ${lib.concatMapStringsSep "\n" (c: "  hl.exec_cmd(${str c})") startupCommands}
              end'')
          ];
        }
      ];

      bind = [

        (bind "${mod} + Q" (exec "kitty"))
        (bind "${mod} + T" (exec "ghostty"))
        (bind "${mod} + C" "hl.dsp.window.close()")
        (bind "${mod} + F" (exec "firefox"))
        (bind "${mod} + M" "hl.dsp.exit()")
        (bind "${mod} + SPACE" (exec "wofi --show drun"))
        (bind "${mod} + V" "hl.dsp.window.float({ action = ${str "toggle"} })")

        # Move the active window to workspace 10
        (bind "${mod} + SHIFT + 0" "hl.dsp.window.move({ workspace = 10 })")

        # Mouse binds (was `bindm`)
        (bindOpts "${mod} + mouse:272" "hl.dsp.window.drag()" "{ mouse = true }")
        (bindOpts "${mod} + mouse:273" "hl.dsp.window.resize()" "{ mouse = true }")

      ]
      ++ directionBinds
      ++ workspaceBinds;

    };
  };

  # Packages needed for this specific desktop
  home.packages = with pkgs; [
    kitty       # Kitty for backup
    wofi
    swww
    pavucontrol # Audio control
    blueman     # Bluetooth manager (used by waybar bluetooth module)
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


}
