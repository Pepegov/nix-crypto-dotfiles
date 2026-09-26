{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings.user.name = "pepegov";
    settings.user.email = "andelismore@gmail.com";
  };
}