{ lib, pkgs, ... }:

{
  imports = [
    ./disco.nix
    ./hardware-configuration.nix
    ../../modules/security.nix
    ../../modules/networking.nix
    ../../modules/desktop.nix
    ../../modules/trezor.nix
    ../../modules/browser.nix
    ../../modulrs/git.nix
  ];

  networking.hostName = "crypto-vm";
  time.timeZone = "Europe/Moscow";

  # The host supplies OVMF/UEFI; no guest EFI variables are written. Secure
  # Boot is intentionally not enabled because host-controlled firmware cannot
  # establish a trust boundary against the host.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  # This account is deliberately ordinary. Set its password interactively during
  # installation with passwd; no password hash belongs in this repository.
  users.users.crypto = {
    isNormalUser = true;
    description = "Crypto operations user";
    extraGroups = [ "wheel" "trezord" ];
  };
  users.groups.trezord = { };

  environment.systemPackages = with pkgs; [
    trezor-suite
  ];

  # Trezor Suite is the only unfree package. Restricting this avoids making an
  # accidental future unfree dependency acceptable without an explicit review.
  nixpkgs.config.allowUnfreePredicate = pkg: lib.getName pkg == "trezor-suite";

  system.stateVersion = "26.05";
}
