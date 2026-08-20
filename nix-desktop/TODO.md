# TODO

Outstanding work on the `nix-desktop` tree. Paths are relative to this
directory. Completed items are removed rather than ticked -- `git log` is the
record of what was done and why.

Two decisions are settled and deliberately *not* listed here as work, because
each is documented at the code site that would otherwise invite redoing it:
alr-game's NVIDIA driver is pinned by hand for a Pascal card
(`alr-game/nixos/configuration.nix`), and store cleanup stays manual with no
`nix.gc` timer (`common/nixos/nix.nix`).

## Pending on the machines

None of this is a code change -- it is work the repo cannot do for itself.
State recorded 2026-08-20, verified on alr-work; the lines about the other two
hosts are carried over and not re-checked.

- [ ] **Switch all three hosts.** *Verified* on alr-work: generation 104 runs
  `kv2rz2108kw3g6sd0xd7bg8angfx4n34`, while `main` evaluates to
  `b3yyix2zjsl4r3hsm26ivygj1j8kcpmy`. Nothing has been switched anywhere since
  the ssh migration, so everything committed since then is inert: the shared
  base modules, the git identity, mako, the ESP change, hyprlock on alr-home,
  the unifi removal, and the whole of the 2026-08-20 review work.
  `nixos-rebuild switch --flake .`

- [ ] **Push `main`.** `origin/main` sits at `dc60049`. Unpushed: the five bug
  fixes, the nm-applet/brightnessctl move, adb on alr-home, and the edits to
  this file. No count here on purpose -- it was wrong last time, because the
  ssh migration, the home-manager fixes, mako and the ESP change were pushed
  after the number was written down. `git log origin/main..main` is the answer.

- [ ] **Remount `/boot` on alr-work.** *Re-verified 2026-08-20*: still mounted
  `fmask=0022,dmask=0022`. Switching does not remount an already-mounted
  filesystem, so this needs `mount -o remount /boot` or a reboot before the
  0077 in the config is real.

- [ ] **Remove `~/.gitconfig` on each host,** after switching. *Re-verified on
  alr-work 2026-08-20*: the hand-written file is still there (117 bytes, dated
  2025-11-10) and `git config --get user.email` still answers from it;
  `~/.config/git/config` does not exist yet, which is expected before a switch.
  The declarative identity stays inert until the old file is gone.

- [ ] **Test hyprlock on alr-home before letting it lock by itself.** That
  switch turns the lock screen on for the first time, and hypridle will lock
  the session after 300s idle. If `security.pam.services.hyprlock` is not
  working on that host, a correct password will be refused on a session that
  is already running -- recoverable only by switching VT and killing hyprlock.
  Run `hyprlock` by hand from a terminal straight after switching and confirm
  it unlocks, before walking away.

- [ ] **Decide what happens to `/var/lib/unifi` on alr-game.** `services.unifi`
  was removed from the config, so switching stops the daemon and leaves the
  controller's state directory behind. Nothing deletes it -- keep it if the
  controller may come back elsewhere, otherwise remove it by hand.

- [ ] **Look at what the 2026-08-20 fixes changed,** once each host is
  switched. None of it can be checked from the repo:

  - `SUPER + SHIFT + S`. The region grab is still the one path in the
    screenshot tool never exercised by a human -- it needs a real pointer drag.
    Window and output modes were run and produced correct captures. With mako
    installed, a "Screenshot saved" notification should appear too.
  - The hyprlock clock should now render in JetBrainsMono bold rather than
    DejaVu Sans Mono, and match the SDDM greeter's clock.
  - The hyprlock password field should read `Password...` with no visible
    `<i>` tags around it.
  - `SUPER + 0` should focus workspace 10 -- on both laptops that is the
    internal panel.
  - `adb devices` should work on alr-home. A phone shows as `unauthorized`
    until the "Allow USB debugging?" prompt is accepted on the handset; that
    is the phone's own key confirmation, not a permissions problem.

## Documentation and dead code

- [ ] **README calls alr-home a desktop.** `README.md:4` describes the three
  machines as a work laptop, "a home desktop (`alr-home`)", and a gaming box.
  alr-home drives `eDP-1`, sets `lidOutput = "eDP-1"`, keeps `battery` in its
  waybar modules, and boots LUKS-on-laptop -- it is a laptop. alr-game is the
  only desktop of the three.

- [ ] **`common/home-manager/base.nix` contradicts itself about syntax
  highlighting.** Line 89 sets `syntaxHighlighting.enable` for all three hosts,
  and the comment above it says so. The longer comment at line 115 then says
  highlighting "comes from `programs.zsh.syntaxHighlighting.enable`, which only
  alr-game sets" -- true before the option moved into this file, wrong now, and
  sitting twenty-six lines below the line that disproves it.

- [ ] **Delete `alr-work/nixos/hyprland-changes-configuration.txt`.** Fifty-five
  lines of scratch NixOS config from the Hyprland migration -- the graphics
  stack, SDDM, fonts and `NIXOS_OZONE_WL` block it proposes all shipped in
  `common/nixos/desktop.nix`. Nothing imports it (it is a `.txt`), and it
  contradicts the tree in places, e.g. proposing `plasma6.enable = false`.

## Stale or fragile

- [ ] **alr-game's NVIDIA driver has exactly one source** — the pinned
  580.95.05 is not a version nixpkgs builds, so no binary cache carries it.
  *Verified*: `nix path-info --store https://cache.nixos.org` reports the src
  path as **not valid**; only NVIDIA's CDN has it, and it still answers 200.
  If that URL is retired, alr-game keeps running on the store path it has but
  can no longer rebuild the driver -- a reinstall, or a GC once the path is
  unreferenced, would leave it stranded.

  A hash-verified copy sits in `~/backup/NVIDIA-Linux-x86_64-580.95.05.run` on
  alr-work, which is a copy on one disk, not a backup. To close this: host the
  file somewhere durable and add it to the `fetchurl` call, which takes a
  `urls` list and tries them in order. Note `fetchurl` throws if given both
  `url` and `urls`, so it is a swap, not an addition. The hash is unchanged, so
  it rebuilds nothing.

- [ ] **Nothing records why `hyprland` does not follow `nixpkgs`.** The flake
  gives `hyprland` its own nixpkgs, so two nixpkgs trees are locked and
  evaluated (`nixpkgs` at 2026-08-09 for Hyprland, `nixpkgs_2` at 2026-08-16
  for the hosts). That is correct and load-bearing: adding
  `inputs.nixpkgs.follows = "nixpkgs"` would rebuild the compositor against a
  different tree and miss every binary in `hyprland.cachix.org` -- the exact
  cost `common/nixos/nix.nix` exists to avoid. But `flake.nix` says nothing
  about it, and deduplicating that input is precisely the tidy-up a future
  reader reaches for. Belongs as a comment at the input, next to the two other
  settled decisions.

- [ ] **The lock screen and greeter backgrounds are two defaults that must
  match.** `local.hyprlock.background` and `local.sddmTheme.background` each
  default to `../../wallpaper/LM-Backgrop.png` independently. The comments in
  both files describe them as deliberately the same file, but setting one on a
  host silently leaves the other behind, and nothing fails when they diverge.
  Either derive one from the other or assert they are equal. (The file itself
  is misspelled -- `Backgrop` for `Backdrop` -- if it is ever worth a rename.)

## Open questions

- [ ] `services.displayManager.defaultSession = "hyprland"` only decides what
  runs when nothing is remembered -- `SessionModel::selectDefaultSession()`
  checks `/var/lib/sddm/state.conf` first. Making it authoritative would mean
  resolving the session in the theme.

- [ ] `networking.nameservers = [ "1.1.1.1" ]` in `common/nixos/base.nix` pins
  one resolver, with no secondary, on all three hosts -- including two laptops
  that roam between networks, one of which carries internal-only names in
  `alr-work/nixos/hosts.nix`. Worth deciding whether that should be a fallback
  rather than an override, and whether a second address belongs alongside it.

- [ ] `waybar.nix` and `ghostty.nix` are the only modules in
  `common/home-manager/` with no `local.<name>.enable` gate -- importing them
  turns them on. Every other module there (hyprlock, hypridle, mako,
  screenshot, hyprland) takes an explicit enable. All three hosts want both
  today, so this costs nothing yet; the question is whether the pattern should
  be uniform.

- [ ] alr-game has no wireless radio and no bluetooth adapter, which is now
  reflected in the config (its waybar modules, and the applet/brightnessctl
  packages that moved to the two laptops). What is left is `networking`:
  `common/nixos/base.nix` enables NetworkManager on all three hosts, which on
  a wired-only box is a daemon and a D-Bus service to manage one static
  ethernet link. It works and it keeps `nmcli` uniform across hosts, so this
  is a question of taste rather than a defect -- but systemd-networkd or plain
  DHCP would be the smaller thing to run there.

- [ ] Dropping `bluetooth` from alr-game's `modulesRight` stops the module from
  running, but the shared `waybar.nix` still emits the `bluetooth` settings
  block for every host, and its `on-click` embeds `${pkgs.blueman}/bin/...` --
  so blueman stays in alr-game's closure through that string reference even
  though nothing on the host can use it. Gating the block on whether
  `bluetooth` appears in `modulesRight` would make the removal real; the cost
  is coupling the settings to the module list. Same applies to `battery`,
  which alr-game and every host still emit config for.
