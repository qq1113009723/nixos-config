{ config, lib, ... }:

{
  options.userSettings.git = {
    enable = lib.mkEnableOption "Enable programs.git";
    useProxy = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to set git http/https proxy settings";
    };
    proxy = lib.mkOption {
      type = lib.types.str;
      default = "http://192.168.106.171:7890";
      description = "Proxy URL to use when userSettings.git.useProxy is true";
    };
  };

  config = lib.mkIf config.userSettings.git.enable {
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
