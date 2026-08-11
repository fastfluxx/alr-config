# Helpers for building Hyprland 0.56 Lua configs through home-manager.
#
# home-manager's configType = "lua" renders settings.<key> = <value> as
# hl.<key>(<value>). Two escape hatches make the real API reachable:
#
#   _args        renders an attrset as a multi-argument call rather than a table
#   mkLuaInline  emits raw Lua instead of a quoted string
#
# so that hl.bind("SUPER + Q", hl.dsp.exec_cmd("kitty")) is expressible.
{ lib }:

rec {
  inherit (lib.generators) mkLuaInline;

  # A Lua-safe quoted string literal.
  str = builtins.toJSON;

  # hl.bind(keys, dispatcher)
  bind = keys: dispatcher: { _args = [ keys (mkLuaInline dispatcher) ]; };

  # hl.bind(keys, dispatcher, opts)
  bindOpts = keys: dispatcher: opts: {
    _args = [ keys (mkLuaInline dispatcher) (mkLuaInline opts) ];
  };

  # A dispatcher that shells out.
  exec = cmd: "hl.dsp.exec_cmd(${str cmd})";
}
