{
  config,
  lib,
  pkgs,
  ...
}:
let 
  cfg = config.userSettings.jetbrains.idea;
in
{
  options = {
    userSettings.jetbrains.idea = {
      enable = lib.mkEnableOption "Enable jetbrains.idea";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.jetbrains.idea
    ];
  };

}