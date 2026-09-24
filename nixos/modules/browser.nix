{ ... }:

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
}
