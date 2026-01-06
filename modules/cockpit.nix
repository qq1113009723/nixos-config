{
  config, pkgs, lib,...
}:{
  options = {
    systemSettings.cockpit = {
      enable = lib.mkEnableOption "Enable cockpit service";
    };
  };
  config = lib.mkIf config.systemSettings.cockpit.enable {
    services.cockpit = {
      enable = true;
      port = 9090;
    };
  };
}