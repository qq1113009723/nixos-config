{ config,lib,pkgs, unfreePkgs,inputs, system, ... }:

{
  options = {
    userSettings.code-cursor = {
      enable = lib.mkEnableOption "Enable code-cursor";
    };
  };
  config = lib.mkIf config.userSettings.code-cursor.enable {
    home.packages = [
      unfreePkgs.code-cursor
    ];
  };

}
