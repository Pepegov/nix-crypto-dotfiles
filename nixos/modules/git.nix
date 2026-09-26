{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    config.user.name = "pepegov";
    config.user.email = "andelismore@gmail.com";
  };
}
