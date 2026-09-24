{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableFormHistory = true;
      PasswordManagerEnabled = false;
      # Extensions are intentionally opt-in through a reviewed configuration
      # change, not a click in a sensitive browsing profile.
      ExtensionSettings."*".installation_mode = "blocked";
    };
  };

  # Brave is an isolated Chromium profile for the only EVM wallet extension in
  # this VM. Launch it from XFCE as "Brave Rabby"; do not use the regular Brave
  # launcher, which would create a separate profile.
  environment.systemPackages = [
    pkgs.brave
    (pkgs.makeDesktopItem {
      name = "brave-rabby";
      desktopName = "Brave Rabby";
      genericName = "Dedicated Rabby Wallet browser";
      exec = "${pkgs.brave}/bin/brave --user-data-dir=/home/crypto/.local/share/brave-rabby --no-first-run %U";
      icon = "brave";
      categories = [ "Network" "WebBrowser" ];
    })
  ];

  # Brave reads Linux enterprise policies from /etc/brave/policies/managed.
  # The extension ID and update endpoint are the official Chrome Web Store
  # values for Rabby Wallet. Updates still come from the extension publisher,
  # as declared in its signed extension manifest.
  environment.etc."brave/policies/managed/rabby.json".text = builtins.toJSON {
    AutofillAddressEnabled = false;
    AutofillCreditCardEnabled = false;
    BrowserAddPersonEnabled = false;
    BrowserSignin = 0;
    IncognitoModeAvailability = 1;
    PasswordManagerEnabled = false;
    SyncDisabled = true;

    ExtensionSettings = {
      "*" = {
        installation_mode = "blocked";
        blocked_install_message = "Only the reviewed Rabby Wallet extension is allowed in this VM.";
      };
      "acmacodkjbdgmoleebolmdjonilkdbch" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };
    };
  };
}
