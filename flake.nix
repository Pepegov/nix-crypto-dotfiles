{
  description = "Minimal, compartmentalized NixOS VM for cryptocurrency operations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, home-manager }:
    let
      system = "x86_64-linux";
      homePkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg:
          nixpkgs.lib.getName pkg == "trezor-suite";
      };
    in
    {
      apps.${system}.disko = {
        type = "app";
        program = "${disko.packages.${system}.default}/bin/disko";
      };

      homeConfigurations.crypto = home-manager.lib.homeManagerConfiguration {
        pkgs = homePkgs;
        modules = [ ./home-manager/crypto.nix ];
      };

      nixosConfigurations.crypto-vm = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          disko.nixosModules.disko
          ./nixos/hosts/crypto-vm/configuration.nix
          ({ pkgs, ... }: {
            environment.systemPackages = [
              home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
            ];
          })
        ];
      };
    };
}
