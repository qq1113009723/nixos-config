{
  config,
  lib,
  pkgs,
  system,
  ...
}:
let
  cfg = config.userSettings.clash-verge-rev;
in
{
  options = {
    userSettings.clash-verge-rev = {
      enable = lib.mkEnableOption "Enable Clash Verge (a graphical user interface for Clash)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =  [
      pkgs.clash-verge-rev
    ];

  };
}

