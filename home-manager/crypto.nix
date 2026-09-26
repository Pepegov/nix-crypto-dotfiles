{ pkgs, ... }:

{
  home.username = "crypto";
  home.homeDirectory = "/home/crypto";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    greybird
    elementary-xfce-icon-theme
    xfce4-notifyd
    xfce4-pulseaudio-plugin
    xfce4-power-manager
    xfce4-terminal
    xfce4-whiskermenu-plugin
  ];

  xdg.configFile = {
    # udev starts Suite when a Trezor is passed through during an active
    # session. This handles the complementary case: the Trezor was attached to
    # the VM before the user logged in. It does nothing when no Trezor is
    # present and does not start a bridge daemon.
    "autostart/trezor-suite-if-connected.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Open Trezor Suite when Trezor is connected
      Exec=${pkgs.writeShellScript "trezor-suite-if-connected" ''
        for device in /sys/bus/usb/devices/*; do
          if [ -r "$device/idVendor" ] && [ "$(< "$device/idVendor")" = "534c" ]; then
            exec ${pkgs.trezor-suite}/bin/trezor-suite
          fi
        done
      ''}
      OnlyShowIn=XFCE;
      X-GNOME-Autostart-enabled=true
    '';

    "xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <channel name="xfce4-panel" version="1.0">
        <property name="panels" type="array">
          <value type="int" value="1"/>
          <property name="panel-1" type="empty">
            <property name="position" type="string" value="p=6;x=0;y=0"/>
            <property name="length" type="uint" value="100"/>
            <property name="position-locked" type="bool" value="true"/>
            <property name="plugin-ids" type="array">
              <value type="int" value="1"/>
              <value type="int" value="2"/>
              <value type="int" value="3"/>
              <value type="int" value="4"/>
              <value type="int" value="5"/>
              <value type="int" value="6"/>
              <value type="int" value="7"/>
              <value type="int" value="8"/>
              <value type="int" value="9"/>
            </property>
            <property name="background-style" type="uint" value="0"/>
            <property name="size" type="uint" value="24"/>
            <property name="length-adjust" type="bool" value="true"/>
            <property name="span-monitors" type="bool" value="false"/>
            <property name="mode" type="uint" value="0"/>
            <property name="autohide-behavior" type="uint" value="0"/>
          </property>
        </property>
        <property name="plugins" type="empty">
          <property name="plugin-1" type="string" value="whiskermenu"/>
          <property name="plugin-2" type="string" value="separator">
            <property name="style" type="uint" value="0"/>
            <property name="expand" type="bool" value="false"/>
          </property>
          <property name="plugin-3" type="string" value="tasklist">
            <property name="show-handle" type="bool" value="false"/>
            <property name="flat-buttons" type="bool" value="true"/>
          </property>
          <property name="plugin-4" type="string" value="separator">
            <property name="style" type="uint" value="0"/>
            <property name="expand" type="bool" value="true"/>
          </property>
          <property name="plugin-5" type="string" value="systray">
            <property name="menu-is-primary" type="bool" value="true"/>
            <property name="show-frame" type="bool" value="false"/>
            <property name="square-icons" type="bool" value="true"/>
            <property name="size-max" type="uint" value="22"/>
            <property name="symbolic-icons" type="bool" value="true"/>
            <property name="icon-size" type="int" value="0"/>
          </property>
          <property name="plugin-6" type="string" value="notification-plugin"/>
          <property name="plugin-7" type="string" value="power-manager-plugin"/>
          <property name="plugin-8" type="string" value="pulseaudio">
            <property name="enable-keyboard-shortcuts" type="bool" value="true"/>
            <property name="show-notifications" type="bool" value="true"/>
          </property>
          <property name="plugin-9" type="string" value="clock">
            <property name="digital-format" type="string" value=" %d %b, %H:%M "/>
          </property>
        </property>
        <property name="configver" type="int" value="2"/>
      </channel>
    '';

    "xfce4/xfconf/xfce-perchannel-xml/xsettings.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <channel name="xsettings" version="1.0">
        <property name="Net" type="empty">
          <property name="ThemeName" type="string" value="Greybird"/>
          <property name="IconThemeName" type="string" value="elementary-xfce"/>
          <property name="FallbackIconTheme" type="string" value="gnome"/>
        </property>
        <property name="Xft" type="empty">
          <property name="DPI" type="int" value="96"/>
          <property name="Antialias" type="int" value="1"/>
          <property name="Hinting" type="int" value="1"/>
          <property name="HintStyle" type="string" value="hintslight"/>
          <property name="RGBA" type="string" value="rgb"/>
        </property>
        <property name="Gtk" type="empty">
          <property name="CursorThemeName" type="string" value="DMZ-White"/>
          <property name="CursorThemeSize" type="int" value="24"/>
          <property name="DecorationLayout" type="string" value="menu:minimize,maximize,close"/>
          <property name="FontName" type="string" value="Noto Sans 9"/>
        </property>
        <property name="Xfce" type="empty">
          <property name="SyncThemes" type="bool" value="true"/>
        </property>
      </channel>
    '';

    "xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <channel name="xfwm4" version="1.0">
        <property name="general" type="empty">
          <property name="theme" type="string" value="Greybird"/>
          <property name="title_font" type="string" value="Noto Sans Bold 9"/>
        </property>
      </channel>
    '';

    "xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <channel name="xfce4-keyboard-shortcuts" version="1.0">
        <property name="commands" type="empty">
          <property name="custom" type="empty">
            <property name="&lt;Super&gt;Return" type="string" value="xfce4-terminal"/>
          </property>
        </property>
      </channel>
    '';
  };
}
