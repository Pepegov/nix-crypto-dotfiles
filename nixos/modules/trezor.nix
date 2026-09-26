{ pkgs, ... }:

{
  # These are the maintained rules from the pinned nixpkgs source. They grant
  # access only to devices matching Trezor's vendor/product rules, via trezord.
  services.udev.packages = [ pkgs.trezor-udev-rules ];

  # Start Suite only after an explicitly passed-through Trezor appears in the
  # guest. A physical connection to the host does not trigger this rule. The
  # service is transient: it launches the desktop application and does not
  # create a persistent Trezor bridge daemon.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="534c", TAG+="systemd", ENV{SYSTEMD_WANTS}+="trezor-suite-launch.service"
  '';

  systemd.services.trezor-suite-launch = {
    description = "Launch Trezor Suite after Trezor USB passthrough";
    after = [ "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "crypto";
      Environment = [
        "DISPLAY=:0"
        "XAUTHORITY=/home/crypto/.Xauthority"
      ];
      ExecStart = "${pkgs.trezor-suite}/bin/trezor-suite";
    };
  };

  # Deliberately do not enable services.trezord. Trezor Suite desktop includes
  # its own bridge executable when needed; a permanent system bridge would add
  # an always-running local HTTP service with no benefit to this workflow.
}
