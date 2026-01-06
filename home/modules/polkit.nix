{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.userSettings.polkit = {
    enable = lib.mkEnableOption "polkit-gnome service";
  };

  config = lib.mkIf config.userSettings.polkit.enable {
    services.polkit-gnome = {
      enable = true;
    };
  };
}