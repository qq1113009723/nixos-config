{
  config, pkgs, lib,...
}:{
  options = {
    systemSettings.flatpak = {
      enable = lib.mkEnableOption "Enable flatpak service";
    };
  };

  config = lib.mkIf config.systemSettings.flatpak.enable {
    services.flatpak = {
      enable = true;
    };
  };
}
