{
  description = "Flake config for alr desktop";

  inputs = {

    #nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

  };


  outputs = { self, nixpkgs, home-manager, hyprland, ... } @ inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    # Attribute names match networking.hostName so that a bare
    # `nixos-rebuild switch --flake .` resolves on each machine.
    hosts = {
      alr-workstation = ./alr-work;
      alr-home = ./alr-home;
      alr-game = ./alr-game;
    };

    # home-manager runs as a NixOS module, so one `nixos-rebuild switch`
    # applies both the system and the user config, and both roll back together.
    mkHost = dir: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        (dir + "/nixos/configuration.nix")
        (dir + "/nixos/hardware-configuration.nix")
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users.alr = import (dir + "/home-manager/home.nix");
          };
        }
      ];
    };

    # Hyprland 0.56 silently falls back to a generated default config when it
    # cannot parse the one it is given, so a broken config looks like a normal
    # login. Parse it at build time instead.
    mkHyprlandCheck = name: host:
      pkgs.runCommand "hyprland-config-${name}" { } ''
        export HOME="$PWD" XDG_RUNTIME_DIR="$PWD"
        cp ${host.config.home-manager.users.alr.home-files}/.config/hypr/hyprland.lua ./hyprland.lua

        result=$(${host.config.programs.hyprland.package}/bin/Hyprland \
          --verify-config -c ./hyprland.lua 2>&1 || true)
        echo "$result"

        if ! echo "$result" | grep -q 'config ok'; then
          echo "Hyprland rejected the generated config for ${name}" >&2
          exit 1
        fi
        touch "$out"
      '';
  in {

    nixosConfigurations = builtins.mapAttrs (_: mkHost) hosts;

    checks.${system} =
      nixpkgs.lib.mapAttrs' (name: host:
        nixpkgs.lib.nameValuePair "hyprland-config-${name}" (mkHyprlandCheck name host)
      ) self.nixosConfigurations;

  };
}
