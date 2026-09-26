{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce = {
    enable = true;
    enableScreensaver = true;
  };

  # Keep the conventional XFCE session but leave document/media viewers and
  # screenshot tools out of this purpose-specific VM. Mousepad is retained as
  # the small local text editor for notes that contain no secrets.
  environment.xfce.excludePackages = with pkgs; [
    parole
    ristretto
    xfce4-screenshooter
    xfce4-taskmanager
  ];
}
