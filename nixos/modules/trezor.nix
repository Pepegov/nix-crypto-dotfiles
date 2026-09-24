{ pkgs, ... }:

{
  # These are the maintained rules from the pinned nixpkgs source. They grant
  # access only to devices matching Trezor's vendor/product rules, via trezord.
  services.udev.packages = [ pkgs.trezor-udev-rules ];

  # Deliberately do not enable services.trezord. Trezor Suite desktop includes
  # its own bridge executable when needed; a permanent system bridge would add
  # an always-running local HTTP service with no benefit to this workflow.
}
