{ config, lib, ... }:
let
  inherit (lib) 
    mkIf
    mkEnableOption
    mkOption
    types
  ;
in  

{
  options.userSettings.git = {
    enable = mkEnableOption "Enable programs.git";
    useProxy = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to set git http/https proxy settings";
    };
    proxy = mkOption {
      type = types.str;
      default = "http://192.168.106.171:7890";
      description = "Proxy URL to use when userSettings.git.useProxy is true";
    };
  };

  config = mkIf config.userSettings.git.enable {
    programs.git.enable = true;

    programs.git.settings = (
      let 
          base = {
            user = {
              name = "zhoujinqiu";
              email = "1113009723@qq.com";
            };
            credential = {
              helper = "store";
            };
          };
      in 
      if config.userSettings.git.useProxy then base // {
          http = { proxy = config.userSettings.git.proxy; };
          https = { proxy = config.userSettings.git.proxy; };
      } else base
    );
  };
}
