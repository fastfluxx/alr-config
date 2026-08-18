# Shared Hyprland desktop. Hosts supply only what actually differs: monitors,
# workspace placement, and any extra binds.
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.local.hyprland;

  hypr = import ../lib/hypr.nix { inherit lib; };
  inherit (hypr) bind bindOpts exec str;

  mod = cfg.modifier;

  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";

  wallpaperTarget = "wallpapers/${builtins.baseNameOf (toString cfg.wallpaper)}";

  directionBinds = lib.concatMap (d: [
    (bind "${mod} + ${d}" "hl.dsp.focus({ direction = ${str d} })")
    (bind "${mod} + CONTROL + ${d}" "hl.dsp.window.move({ direction = ${str d} })")
  ]) [ "left" "right" "up" "down" ];

  workspaceBinds = lib.concatMap (i: [
    (bind "${mod} + ${toString i}" "hl.dsp.focus({ workspace = ${toString i} })")
    (bind "${mod} + SHIFT + ${toString i}" "hl.dsp.window.move({ workspace = ${toString i} })")
  ]) (lib.range 1 9);

  # Lid handling. Hyprland 0.56 dropped hyprlang and with it `hyprctl keyword`,
  # so the monitor is driven through hl.monitor() over `hyprctl eval`. That call
  # merges into the existing rule rather than replacing it, which is why
  # `disabled` is set explicitly in both directions -- omitting it on the way
  # back up would leave the panel switched off.
  lidMonitor = lib.findFirst (m: (m.output or "") == cfg.lidOutput) null cfg.monitors;

  lidBinds = lib.optionals (lidMonitor != null) (
    let
      output = str cfg.lidOutput;
      mode = str (lidMonitor.mode or "preferred");
      position = str (lidMonitor.position or "auto");
      scale = toString (lidMonitor.scale or 1);
    in
    [
      (bindOpts "switch:on:Lid Switch"
        (exec "hyprctl eval 'hl.monitor({ output = ${output}, disabled = true })'")
        "{ locked = true }")
      (bindOpts "switch:off:Lid Switch"
        (exec "hyprctl eval 'hl.monitor({ output = ${output}, mode = ${mode}, position = ${position}, scale = ${scale}, disabled = false })'")
        "{ locked = true }")
    ]);

  # Hyprland 0.56 has no exec-once; the equivalent is a hyprland.start handler.
  # home-manager emits its own handler for systemd activation, so nothing here
  # needs to repeat dbus-update-activation-environment.
  startupCommands =
    lib.optionals (cfg.wallpaper != null) [
      "${pkgs.awww}/bin/awww-daemon"
      # The binaries are named awww/awww-daemon; pkgs.swww is the same derivation
      # and ships no swww command at all.
      "sleep 1 && ${pkgs.awww}/bin/awww img ${config.home.homeDirectory}/${wallpaperTarget} --transition-type fade --transition-duration 2"
    ]
    ++ lib.optional config.home.pointerCursor.enable
      "${hyprctl} setcursor ${config.home.pointerCursor.name} ${toString config.home.pointerCursor.size}"
    ++ cfg.startupCommands;
in
{
  options.local.hyprland = {
    enable = lib.mkEnableOption "the shared Hyprland desktop";

    modifier = lib.mkOption {
      type = lib.types.str;
      default = "SUPER";
      description = "Primary modifier for all keybindings.";
    };

    monitors = lib.mkOption {
      type = with lib.types; listOf (attrsOf anything);
      default = [ ];
      example = [{ output = "DP-7"; mode = "3440x1440@99.98"; position = "0x0"; scale = 1; }];
      description = "hl.monitor() specs. An empty `output` matches any monitor.";
    };

    workspaceMonitors = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = { "1" = "DP-7"; "10" = "eDP-1"; };
      description = "Workspace number to monitor output, rendered as hl.workspace_rule().";
    };

    lidOutput = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "eDP-1";
      description = ''
        Internal panel to switch off while the lid is shut, and back on when it
        opens. Its mode, position and scale come from the matching `monitors`
        entry, so a monitor moved in the layout cannot drift out of step with
        the lid binds.
      '';
    };

    startupCommands = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra commands to run from the hyprland.start handler.";
    };

    extraBinds = lib.mkOption {
      type = lib.types.listOf lib.types.anything;
      default = [ ];
      description = "Extra binds, built with the helpers in common/lib/hypr.nix.";
    };

    wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Wallpaper image, installed into ~/wallpapers and set at session start.";
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [{
      assertion = cfg.lidOutput == null || lidMonitor != null;
      message = "local.hyprland.lidOutput is ${toString cfg.lidOutput}, which is not one of the configured monitors.";
    }];

    home.file = lib.mkIf (cfg.wallpaper != null) {
      ${wallpaperTarget}.source = cfg.wallpaper;
    };

    home.packages = with pkgs; [
      kitty # Kitty for backup
      wofi
      awww
      pavucontrol # Audio control
    ];

    home.pointerCursor = {
      # Without this the other options here are inert -- home-manager only
      # installs the theme and sets XCURSOR_* when enable is set.
      enable = true;
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
      gtk.enable = true;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = null;

      # Hyprland 0.56 dropped hyprlang; hyprland.conf is no longer read at all.
      configType = "lua";

      settings = {

        env = map (e: { _args = e; }) [
          [ "XCURSOR_THEME" config.home.pointerCursor.name ]
          [ "XCURSOR_SIZE" (toString config.home.pointerCursor.size) ]
          # Ghostty
          [ "QT_QPA_PLATFORM" "wayland" ]
          [ "GDK_BACKEND" "wayland" ]
          [ "XDG_SESSION_TYPE" "wayland" ]
        ];

        monitor = cfg.monitors;

        workspace_rule = lib.mapAttrsToList (ws: output: {
          workspace = ws;
          monitor = output;
        }) cfg.workspaceMonitors;

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

        on = lib.optional (startupCommands != [ ]) {
          _args = [
            "hyprland.start"
            (hypr.mkLuaInline ''
              function()
              ${lib.concatMapStringsSep "\n" (c: "  hl.exec_cmd(${str c})") startupCommands}
              end'')
          ];
        };

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
        ++ lib.optional config.programs.hyprlock.enable
          (bind "${mod} + L" (exec "hyprlock"))
        ++ directionBinds
        ++ workspaceBinds
        ++ cfg.extraBinds
        ++ lidBinds;

      };
    };
  };
}
