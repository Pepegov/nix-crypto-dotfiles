{ lib, ... }:

{
  networking.useDHCP = true;
  networking.networkmanager.enable = false;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };

  # Do not make the normal user a trusted Nix user: trusted users can alter
  # settings with implications for the daemon and binary-cache trust.
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = lib.mkForce [ "root" ];
    allowed-users = [ "root" "@wheel" ];
    substituters = lib.mkForce [ "https://cache.nixos.org/" ];
    trusted-public-keys = lib.mkForce [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
}
