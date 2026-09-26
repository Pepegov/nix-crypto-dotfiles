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

  # Brave is an isolated Chromium profile for the reviewed wallet extensions in
  # this VM. Launch it from XFCE as "Brave Wallet"; do not use the regular Brave
  # launcher, which would create a separate profile.
  environment.systemPackages = [
    pkgs.brave
    (pkgs.makeDesktopItem {
      name = "brave-wallet";
      desktopName = "Brave Wallet";
      genericName = "Dedicated wallet browser";
      exec = "${pkgs.brave}/bin/brave --user-data-dir=/home/crypto/.local/share/brave-wallet --no-first-run %U";
      icon = "brave";
      categories = [ "Network" "WebBrowser" ];
    })
  ];

  # Brave reads Linux enterprise policies from /etc/brave/policies/managed.
  # The extension IDs and update endpoint are the official Chrome Web Store
  # values for Rabby Wallet and Trust Wallet. Updates still come from their
  # publishers, as declared in signed extension manifests.
  environment.etc."brave/policies/managed/wallet.json".text = builtins.toJSON {
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
        blocked_install_message = "Only the reviewed wallet extensions are allowed in this VM.";
      };
      "acmacodkjbdgmoleebolmdjonilkdbch" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };
      "egjidjbpglichdcondbcbdnbeeppgdph" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };
    };
  };
}
