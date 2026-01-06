{
  config,
  lib,
  pkgs,
  unfreePkgs,
  ...
}:
let 
  cfg = config.userSettings.jetbrains.idea-ultimate;
in
{
  options = {
    userSettings.jetbrains.idea-ultimate = {
      enable = lib.mkEnableOption "Enable jetbrains.idea-ultimate";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      unfreePkgs.jetbrains.idea-ultimate
    ];
  };

}