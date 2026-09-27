{ config, pkgs, ... }:

{
  # Включение агента GPG
  programs.gnupg.agent = {
    enable = true;
    # Явно указываем пакет pinentry
    # pinentryPackage = pkgs.pinentry-curses;  # для консоли
    # или pinentryPackage = pkgs.pinentry-gnome3;  # для GNOME
    pinentryPackage = pkgs.pinentry-qt;  # для KDE/Qt
    # или pinentryPackage = pkgs.pinentry-tty;  # минимальная консольная версия
    
    # Включите если используете SSH через GPG
    enableSSHSupport = true;
  };
  
  # Важно для корректной работы в терминале
  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent updatestartuptty /bye > /dev/null
  '';

  environment.systemPackages = with pkgs; [
    pass
  ];
}