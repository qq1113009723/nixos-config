{
  config,
  lib,
  pkgs,
  ...
}:
let 
  cfg = config.systemSettings.firefox;
in 
{
  options = {
    systemSettings.firefox = {
      enable = lib.mkEnableOption "Enable firefox";
    };
  };

  config = lib.mkIf cfg.enable {

    programs.firefox = {
      enable = true;
    };

    environment.systemPackages = with pkgs;[
      firefox
    ];
 
  };


}