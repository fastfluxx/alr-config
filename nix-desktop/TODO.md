# TODO

Outstanding work on the `nix-desktop` tree. Paths are relative to this
directory. Completed items are removed rather than ticked -- `git log` is the
record of what was done and why.

Two decisions are settled and deliberately *not* listed here as work, because
each is documented at the code site that would otherwise invite redoing it:
alr-game's NVIDIA driver is pinned by hand for a Pascal card
(`alr-game/nixos/configuration.nix`), and store cleanup stays manual with no
`nix.gc` timer (`common/nixos/nix.nix`).

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

- [ ] **alr-game builds MongoDB from source** — `services.unifi` at
  `alr-game/nixos/configuration.nix:178` pins `mongodbPackage = pkgs.mongodb-7_0`,
  which is not in the binary cache (SSPL), so `mongodb-7.0.39` compiles locally
  on every rebuild that touches it. It is why that host is slow to switch.
  Worth deciding whether the UniFi controller belongs on the gaming machine at
  all.

## Hardening

- [ ] **alr-work's ESP is world-readable** —
  `alr-work/nixos/hardware-configuration.nix:24` mounts `/boot` with
  `fmask=0022` / `dmask=0022`, against `0077` at
  `alr-home/nixos/hardware-configuration.nix:26`. The two machines disagree for
  no reason.

## Minor

- [ ] **Remove `~/.gitconfig` on each host** — `programs.git` now writes
  `~/.config/git/config`, but the hand-written `~/.gitconfig` still exists and
  takes precedence, so the declarative identity is inert until it is gone.
  *Verified* with two scratch configs: with both files present git returns the
  `~/.gitconfig` value; with only the XDG one it returns that. Delete or rename
  `~/.gitconfig` after switching, on all three machines.

## Open questions

- [ ] alr-home has `local.hyprlock.enable = false`, so it has a login screen
  styled after a lock screen that host does not have. One line turns hyprlock on
  there if the pair should match. Note `security.pam.services.hyprlock` was
  removed from that host and needs re-adding alongside it.

- [ ] `services.displayManager.defaultSession = "hyprland"` only decides what
  runs when nothing is remembered -- `SessionModel::selectDefaultSession()`
  checks `/var/lib/sddm/state.conf` first. Making it authoritative would mean
  resolving the session in the theme.
