# Nix daemon settings shared by all three hosts.
#
# This is deliberately the smallest possible file in common/nixos/: it is the
# first piece of the `base.nix` that TODO.md asks for, and it exists now
# because the substituter below is what stops every flake bump from rebuilding
# Hyprland from source.
#
# No `nix.gc` or `nix.optimise` here on purpose. Store cleanup and generation
# deletion are done by hand, through the `nix-clean` alias -- an automatic
# timer would remove rollback targets on its own schedule.
{ ... }:

{
  nix.settings = {
    experimental-features = "nix-command flakes";

    # The flake tracks hyprwm/Hyprland from git rather than a nixpkgs release,
    # so without the project's own cache each `nix flake update` compiles the
    # compositor and its dependency tree on every machine. `extra-` appends
    # rather than replacing, which matters: assigning `substituters` outright
    # would drop cache.nixos.org, since a definition overrides the option's
    # default instead of merging with it.
    extra-substituters = [ "https://hyprland.cachix.org" ];
    extra-trusted-public-keys = [
      # Published at https://hyprland.cachix.org/api/v1/cache/hyprland
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };
}
