{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.systemSettings.hyprland;
in
{
  options = {
    systemSettings.hyprland = {
      enable = lib.mkEnableOption "Enable hyprland";
    };
  };

  config = lib.mkIf cfg.enable {
    # Power key should not shut off computer by defaultPower key shuts of
    #services.logind.powerKey = "suspend";

    # Hyprland
    programs = {
      hyprland = {
        enable = true;
      };
    };

    # Necessary packages
    environment.systemPackages = with pkgs; [
      jq
    ];

    # Keyring
    security.pam.services.login.enableGnomeKeyring = true;
    services.gnome.gnome-keyring.enable = true;

    # Dbus
    services.dbus = {
      enable = true;
      packages = [ pkgs.dconf ];
    };

    programs.dconf.enable = true;

  };
}
