{
  description = "Minimal, compartmentalized NixOS VM for cryptocurrency operations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko }:
    {
      apps.x86_64-linux.disko = {
        type = "app";
        program = "${disko.packages.x86_64-linux.default}/bin/disko";
      };

      nixosConfigurations.crypto-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./nixos/hosts/crypto-vm/configuration.nix
        ];
      };
    };
}
