{
  description = "Flake config for alr desktop";

  inputs = {
    
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    #home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

  };


  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
  let
    inherit (self) outputs;
    system = "x86_64-linux";
    
    # Common arguments passed to all configurations
    sharedArgs = { inherit inputs outputs; };
  in {
    
    # NixOS system config
    nixosConfigurations = {
      alr-home = nixpkgs.lib.nixosSystem {
        specialArgs = sharedArgs;
        modules = [ 
		./alr-home/nixos/configuration.nix 
		./alr-home/nixos/hardware-configuration.nix
		 ];
      };

      alr-work = nixpkgs.lib.nixosSystem {
        specialArgs = sharedArgs;
        modules = [ 
		./alr-work/nixos/configuration.nix 
		./alr-work/nixos/hardware-configuration.nix 
		];
      };

    };

    # Home manager config
    homeConfigurations = {
      "alr-home" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = sharedArgs;
        modules = [ ./alr-home/home-manager/home.nix ];
      };

      "alr-work" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = sharedArgs;
        modules = [ ./alr-work/home-manager/home.nix ];
      };

    };

  };
}
