# TODO

Findings from a review of the whole `nix-desktop` tree (three hosts, the shared
modules, and the flake). Paths are relative to this directory. Anything marked
*verified* was checked against the built system, not just read.

## Bugs

All seven fixed 2026-08-18; kept here for the record of what was wrong and why.

- [x] **`PartOf` misspelt in the blueman unit** — `alr-work/home-manager/home.nix:35`
  has `Partof`, and systemd keys are case-sensitive. *Verified*:
  `systemd-analyze verify` on the generated unit reports
  `Unknown key 'Partof' in section [Unit], ignoring`, so the applet is never
  stopped when the session ends. The unit also duplicates the home-manager
  service that is switched off at `:29` -- delete the unit and set
  `services.blueman-applet.enable = true` instead.

- [x] **Every new shell downloads zsh-autosuggestions from GitHub** —
  `alr-work/home-manager/home.nix:241`, `alr-home/home-manager/home.nix:156`.
  `autosuggestion.enable = true` is already set and the generated `.zshrc`
  sources the plugin from the store on line 8; the `curl` block then fetches
  `master` from raw.githubusercontent.com into `~/.zsh` and sources it a second
  time. Double-load, unpinned, and remote code fetched at shell start. Delete
  the block.

- [x] **`DOTNET_ROOT` points at a different SDK than the one on PATH** —
  `alr-work/home-manager/home.nix:22` resolves to `dotnet-sdk-wrapped-10.0.302`
  while `:107` installs `combinePackages [ dotnet_9.sdk dotnet_10.sdk ]`. The
  CLI resolves SDKs relative to `DOTNET_ROOT`, so SDK 9 is invisible and the
  combine is pointless. Bind the combined package in a `let` and use it for
  both. The same line on `alr-home:23` was a version mismatch too, not merely a
  duplicate: `dotnet-sdk_10` is **10.0.302** while
  `dotnetCorePackages.dotnet_10.sdk` is **10.0.110**.

- [x] **Ghostty's font is not installed** — `common/home-manager/ghostty.nix:10`
  asks for `Monaco`. *Verified*: `fc-match Monaco` returns DejaVu Sans, a
  proportional font, so Ghostty falls back to its bundled default.
  `"JetBrainsMono Nerd Font"` matches waybar and hyprlock. The theme name
  `Catppuccin Mocha` is correct -- it matches the package's themes directory.

- [x] **Dead NVIDIA cursor variables** —
  `alr-game/nixos/configuration.nix:108-109`. *Verified*: neither
  `WLR_NO_HARDWARE_CURSORS` nor `HYPRLAND_NO_HARDWARE_CURSORS`, nor even
  `no_hardware_cursors`, appears anywhere in the Hyprland 0.56 binary. Leftovers
  from the wlroots era.

- [x] **alr-game's workspace rules name an unconfigured monitor** —
  `alr-game/home-manager/hyprland.nix:34` pins workspaces 1-9 to `DP-3`, but
  `monitors` is the catch-all `output = ""` entry and the DP-3 line is commented
  out at `:30`.

- [x] **The greeter theme was built but never used** —
  `common/nixos/sddm-hyprlock/metadata.desktop` had no `QtVersion` key.
  *Verified*: `Greeter::greeterPathForQt` in sddm 0.21 compares the value
  against 5 and appends `-qt<n>` for anything else, so the default of 5 asked
  for a plain `sddm-greeter`. nixpkgs builds only `sddm-greeter-qt6`, and the
  miss is not fatal -- the daemon logged one line,

  ```
  The theme at ".../themes/hyprlock" requires missing ".../bin/sddm-greeter" . Using fallback theme.
  ```

  and served the stock greeter, which looks exactly like a theme that was never
  applied. `sddm.conf` still read `Current=hyprlock` and the theme was in
  `/run/current-system`, so nothing outside the journal showed the problem.
  Set `QtVersion=6`, and the theme derivation now resolves the greeter path the
  same way SDDM does and fails the build when it does not exist.

## Stale or fragile

- [ ] **Replace the hand-rolled NVIDIA pin with the packaged driver** —
  `alr-game/nixos/configuration.nix:42` rewrites `version` and `src` on
  `nvidiaPackages.production` (now **595.91.07**) down to 580.95.05 with a
  hardcoded hash, applying 595-era packaging to a 580 tarball. *Verified*:
  nixpkgs ships `nvidiaPackages.legacy_580` at **580.178.04** -- same branch
  (the last supporting Pascal, so the pin itself is right), properly packaged,
  no hash to maintain:

  ```nix
  package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  ```

- [ ] **Add the Hyprland binary cache** — no `substituters` anywhere in the repo,
  so each flake bump compiles Hyprland and its deps from source. *Verified*: the
  current Hyprland store path is served by `https://hyprland.cachix.org`
  (`nix path-info --store https://hyprland.cachix.org <path>` resolves). Add the
  substituter and its public key to `nix.settings`.

- [ ] **No automatic garbage collection** — only the manual `nix-clean` alias.
  Worth setting `nix.gc.automatic` and `nix.optimise.automatic` on all three
  hosts, which track unstable.

- [ ] **alr-game builds MongoDB from source** — `services.unifi` at
  `alr-game/nixos/configuration.nix:207` pins `mongodbPackage = pkgs.mongodb-7_0`,
  which is not in the binary cache (SSPL), so `mongodb-7.0.39` compiles locally
  on every rebuild that touches it. Noticed while verifying the fixes below --
  it is why that host takes so long to switch. Worth deciding whether the UniFi
  controller belongs on the gaming machine at all.

## Duplication and drift

- [ ] **The ssh migration only half-landed** — `common/home-manager/ssh.nix` is
  imported by alr-home and alr-game, but alr-work keeps an inline `programs.ssh`
  at `home-manager/home.nix:153`. They differ in substance: alr-work uses three
  GitHub keys (two FIDO2 `sk` keys plus `alr.laud`) and sets `IdentityFile` /
  `IdentitiesOnly` on `*`; the shared module has neither and uses `alr.priv`.
  Both generate valid config -- ssh_config keywords are case-insensitive, so the
  lowercase keys work -- so this is drift, not breakage. Give the shared module
  options and import it on alr-work.

- [ ] **The three `configuration.nix` files repeat ~100 lines each** —
  `programs.hyprland`, `hardware.graphics`, pipewire, rtkit, polkit, fonts,
  timezone, i18n, xkb, console, `users.users.alr`, `allowUnfree`,
  `nix.settings`, zsh. The drift is already visible: alr-game's user lacks
  `libvirtd` / `kvm` / `docker`, `sessionVariables` differ, blueman is on two of
  three. `common/nixos/` now exists -- a `base.nix` plus a `desktop.nix` is the
  same refactor already done for hosts and for home-manager.

- [ ] **`home.nix` is triplicated** — 46 / 39 / 33 package entries with heavy
  overlap, plus the duplicated zsh block above.

- [ ] **Dangling `#./hosts.nix`** — `alr-home/nixos/configuration.nix:7` and
  `alr-game/nixos/configuration.nix:7` reference a file that exists only under
  `alr-work/nixos/`, so uncommenting either fails. Move it to
  `common/nixos/hosts.nix` or drop the lines.

- [ ] **alr-work's LUKS device is declared twice** —
  `nixos/hardware-configuration.nix:21` and `nixos/configuration.nix:54`. This
  evaluates only because both give the identical UUID; change one and it becomes
  a conflicting-definition error. The FIDO2 `crypttabExtraOpts` already live in
  `configuration.nix`, so drop the generated line.

## Hardening

- [ ] **The air-gap specialisation is IPv4-only** —
  `alr-game/nixos/configuration.nix:139` sets `iptables -P OUTPUT DROP` with no
  `ip6tables` equivalent, leaving IPv6 egress open in the mode whose whole point
  is blocking egress. Note also that `networking.nameservers = [ "1.1.1.1" ]` is
  unreachable under those rules, so DNS fails rather than resolving locally.

- [ ] **alr-work's ESP is world-readable** — `fmask=0022` / `dmask=0022` in
  `alr-work/nixos/hardware-configuration.nix`, against `0077` on alr-home. The
  two machines disagree for no reason.

## Minor

- [ ] `security.pam.services.hyprlock = {}` on alr-home and alr-game, where
  hyprlock is disabled.
- [ ] waybar's default `modulesRight` includes `battery`; alr-game is a desktop
  and uses the default.
- [ ] oh-my-zsh's `agnoster` theme plus a manual `export PS1` in `initContent` --
  the manual one wins, so the theme setting is inert.
- [ ] No `programs.git` anywhere: the git identity is set imperatively on each
  host despite three machines sharing a config.

## Open questions from the greeter work

- [ ] alr-home has `local.hyprlock.enable = false`, so it now has a login screen
  styled after a lock screen that host does not have. One line turns hyprlock on
  there if the pair should match.
- [ ] `services.displayManager.defaultSession = "hyprland"` only decides what
  runs when nothing is remembered -- `SessionModel::selectDefaultSession()`
  checks `/var/lib/sddm/state.conf` first. Making it authoritative would mean
  resolving the session in the theme.
