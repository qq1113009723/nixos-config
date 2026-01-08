{
  config,
  lib,
  pkgs,
  ...
}:
let 
  cfg = config.systemSettings.cosmic;
in 
{
  options = {
    systemSettings.cosmic = {
      enable = lib.mkEnableOption "Enable COSMIC desktop environment";
      
      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Additional packages to install with COSMIC";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      desktopManager.cosmic.enable = true;
      displayManager.cosmic-greeter.enable = true;
    };

  };
}

