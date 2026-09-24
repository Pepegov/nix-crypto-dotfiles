{ lib, ... }:

{
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
    execWheelOnly = true;
  };
  security.polkit.enable = true;

  # No network or local root login is needed for normal crypto activity.
  services.openssh.enable = false;
  services.displayManager.autoLogin.enable = false;

  # A compromised process cannot inspect unrelated processes with ptrace unless
  # it is their parent. This can inconvenience debuggers, which are not needed.
  boot.kernel.sysctl."kernel.yama.ptrace_scope" = 1;

  # Prevent ordinary users from using eBPF as an extra kernel attack surface.
  # Programs that need unprivileged eBPF tracing will not work.
  boot.kernel.sysctl."kernel.unprivileged_bpf_disabled" = 1;

  # Limit kernel-address and kernel-log disclosure to privileged users. These
  # reduce information useful to local kernel exploits; diagnostics are less
  # convenient for the normal account.
  boot.kernel.sysctl."kernel.kptr_restrict" = 2;
  boot.kernel.sysctl."kernel.dmesg_restrict" = 1;

  # Do not retain crash images that could contain browser sessions or wallet
  # metadata. The cost is reduced post-mortem debugging.
  systemd.coredump.enable = false;
  security.pam.loginLimits = [
    { domain = "*"; type = "hard"; item = "core"; value = "0"; }
  ];

  # This VM has no reason to accept arbitrary removable USB mass storage.
  # Trezor HID/WebUSB uses different drivers and is unaffected. Attaching a USB
  # disk intentionally to the guest will not work without changing this policy.
  boot.blacklistedKernelModules = [ "usb-storage" "uas" "bluetooth" "btusb" ];

  hardware.bluetooth.enable = false;
  services.printing.enable = false;
  services.avahi.enable = false;
  # XFCE enables these for convenience at normal priority. Force them off so
  # its file manager cannot add removable-media and network-mount plumbing.
  services.udisks2.enable = lib.mkForce false;
  services.gvfs.enable = lib.mkForce false;
}
