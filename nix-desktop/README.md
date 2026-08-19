# nix-desktop

NixOS + home-manager flake for three machines: a work laptop/dock
(`alr-workstation`), a home desktop (`alr-home`), and a gaming box (`alr-game`).
All three run Hyprland with waybar, hypridle and (on two of them) hyprlock.

## Layout

```
flake.nix                     inputs, host wiring, checks
common/
  lib/hypr.nix                helpers for writing Hyprland Lua from Nix
  home-manager/
    hyprland.nix              the shared desktop: binds, env, autostart, cursor
    waybar.nix                status bar
    hyprlock.nix              lock screen
    hypridle.nix              idle -> lock -> DPMS off
    ghostty.nix               terminal
alr-work/                     -> nixosConfigurations.alr-workstation
alr-home/                     -> nixosConfigurations.alr-home
alr-game/                     -> nixosConfigurations.alr-game
  nixos/configuration.nix     system config
  nixos/hardware-configuration.nix
  home-manager/home.nix       user packages, shell, git, ...
  home-manager/hyprland.nix   thin: imports common/, sets what differs
wallpaper/                    images referenced by local.hyprland.wallpaper
```

The three machines are similar but not identical, so everything shared lives in
`common/` behind options, and each host file only states its differences —
monitors, workspace placement, and the odd extra bind.

## Building and switching

Attribute names match `networking.hostName`, so on each machine:

```sh
sudo nixos-rebuild switch --flake .
```

home-manager runs as a **NixOS module**, not standalone. One `nixos-rebuild
switch` applies both the system and the user config, and both roll back
together. There is no separate `home-manager switch` step, and no
`homeConfigurations` output.

To build a host you are not currently on:

```sh
nix build .#nixosConfigurations.alr-game.config.system.build.toplevel
```

## Checks

```sh
nix flake check
```

This parses each host's generated Hyprland config with the real Hyprland binary
(`Hyprland --verify-config`) and fails the build if it is rejected.

This check exists for a specific reason. Hyprland does **not** fail loudly on a
bad config: if it cannot find or parse the config it was given, it writes a
stock default and starts normally. A broken config therefore looks exactly like
a successful login with all your settings mysteriously gone, and nothing appears
in any log except one `WARN` line. Running the parser at build time turns that
into an ordinary build failure.

Run it after every `nix flake update`.

## The Hyprland config format

Hyprland 0.56 **removed** the hyprlang `hyprland.conf` format. It reads only
`~/.config/hypr/hyprland.lua`, there is no fallback and no compatibility flag,
and `--config foo.conf` parses the file as Lua too.

home-manager's `wayland.windowManager.hyprland.configType = "lua"` generates
that file, but it is a renderer rather than a translator: it maps
`settings.<key> = <value>` onto `hl.<key>(<value>)`. Reaching the real API needs
two escape hatches, both wrapped in `common/lib/hypr.nix`:

| Helper | Emits |
|---|---|
| `bind "SUPER + Q" (exec "kitty")` | `hl.bind("SUPER + Q", hl.dsp.exec_cmd("kitty"))` |
| `bindOpts keys dsp "{ mouse = true }"` | `hl.bind(keys, dsp, { mouse = true })` |
| `exec "kitty"` | `hl.dsp.exec_cmd("kitty")` |
| `str "toggle"` | `"toggle"` (a Lua string literal) |

Under the hood `_args` makes home-manager render an attrset as a
multi-argument call instead of a table, and `lib.generators.mkLuaInline` emits
raw Lua instead of a quoted string.

Things that moved when 0.56 landed:

| Old hyprlang | 0.56 Lua |
|---|---|
| `$mod = SUPER` | a Nix-level binding; modifiers join with `+`, not spaces |
| `env = KEY,VALUE` | `hl.env("KEY", "VALUE")` |
| `monitor = name, res, pos, scale` | `hl.monitor({ output; mode; position; scale; })` |
| `workspace = 1, monitor:DP-7` | `hl.workspace_rule({ workspace; monitor; })` |
| top-level `general` / `input` | nested inside `hl.config({ ... })` |
| `col.active_border = c1 c2 45deg` | `{ colors = [ c1 c2 ]; angle = 45; }` |
| `bind = $mod, Q, exec, kitty` | `hl.bind("SUPER + Q", hl.dsp.exec_cmd("kitty"))` |
| `bindm` / `bindl` | bind options `{ mouse = true }` / `{ locked = true }` |
| `exec-once` | `hl.on("hyprland.start", function() ... end)` |

Dispatchers are structured now: `killactive` is `hl.dsp.window.close()`,
`movefocus, l` is `hl.dsp.focus({ direction = "left" })`, `movetoworkspace, 3`
is `hl.dsp.window.move({ workspace = 3 })`. The full typed API is documented in
the stub file Hyprland ships:

```sh
$EDITOR "$(nix eval --raw .#nixosConfigurations.alr-workstation.config.programs.hyprland.package)/share/hypr/stubs/hl.meta.lua"
```

## Options provided by `common/`

### `local.hyprland`

| Option | Default | Meaning |
|---|---|---|
| `enable` | `false` | Turn on the shared desktop |
| `modifier` | `"SUPER"` | Primary modifier for every bind |
| `monitors` | `[]` | `hl.monitor()` specs; empty `output` matches any monitor |
| `workspaceMonitors` | `{}` | Workspace number to monitor output |
| `startupCommands` | `[]` | Extra commands for the `hyprland.start` handler |
| `extraBinds` | `[]` | Host-specific binds, built with the `common/lib/hypr.nix` helpers |
| `wallpaper` | `null` | Image installed to `~/wallpapers` and set with `awww` |

The module supplies the shared binds, input and `general` settings, the cursor
theme, and the terminal/launcher packages. `$mod+L` is only emitted when
hyprlock is enabled, so hosts without a lock screen do not get a dead bind.

### `local.hyprlock`

`enable` (default `false`) and `background` (path to the lock wallpaper).
Requires `security.pam.services.hyprlock` on the NixOS side.

### `local.hypridle`

`enable`, `lockTimeout` (default 300s) and `dpmsTimeout` (default 600s). The
lock listener and `lock_cmd` are only emitted when `local.hyprlock.enable` is
set, so a host without a lock screen just gets DPMS instead of silently trying
to run a `hyprlock` that is not installed.

### `local.waybar`

`modulesRight` — the order of the right-hand module group.

## Adding a host

1. Create `<host>/nixos/configuration.nix` with
   `networking.hostName = "<host>"`, and generate
   `<host>/nixos/hardware-configuration.nix`.
2. Create `<host>/home-manager/home.nix` (user packages, shell) importing
   `./hyprland.nix`.
3. Create `<host>/home-manager/hyprland.nix` importing the `common/`
   home-manager modules and setting `local.hyprland.monitors`,
   `local.hyprland.workspaceMonitors`, and whatever else differs.
4. Add `<host> = ./<host>;` to the `hosts` attrset in `flake.nix`. The NixOS
   config, the home-manager config and the Hyprland check are all wired up from
   that one line.

## Updating

```sh
nix flake update          # or: nix flake update hyprland
nix flake check           # catches a Hyprland config format break
sudo nixos-rebuild switch --flake .
```

`nixpkgs` tracks `nixos-unstable` and `hyprland` tracks upstream `master`, so
breaking changes do arrive. If Hyprland ships another config format change,
`nix flake check` will fail with the parser error rather than leaving you to
discover it at the next login. To ride out a break, pin the input to a known
good revision:

```nix
hyprland.url = "github:hyprwm/Hyprland/<rev>";
```

The `hyprland` input deliberately does **not** `follows` nixpkgs, because
upstream builds against its own nixpkgs pin and publishes the result to a binary
cache. That cache is not configured here yet, so moving to a new Hyprland
revision currently compiles it locally (~10 minutes). To get the prebuilt
binaries instead, add to a host's `configuration.nix`:

```nix
nix.settings = {
  substituters = [ "https://hyprland.cachix.org" ];
  trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIITfGmB0md6rn1CJnRTOo=" ];
};
```
