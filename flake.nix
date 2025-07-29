{
  description = "My dotfiles + NixOS desktop + Home-Manager flake";

  inputs = {
    nixpkgs.url                         = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url                    = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, ... }: let
    system = "x86_64-linux";
    pkgs   = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };
    hm = inputs."home-manager";
  in {
    homeConfigurations = {
      desktop = hm.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./modules/home-manager-config.nix ];
      };
    };

    nixosConfigurations = {
      home-desktop = pkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/home-desktop.nix
          hm.nixosModules.home-manager
        ];
      };
    };
  };
}

