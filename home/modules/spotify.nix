{
  config,
  lib,
  pkgs,
  unfreePkgs,
  ...
}:
let 
  cfg = config.userSettings.spotify;
in
{
  options = {
    userSettings.spotify = {
      enable = lib.mkEnableOption "Enable spotify";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      unfreePkgs.spotify
    ];
  };

}