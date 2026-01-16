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
      environmentVariables = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Additional environment variables for Hyprland session. Default values (XCURSOR_THEME, XCURSOR_SIZE) are always included.";
      };
    };
    
  };

  config = lib.mkIf cfg.enable {
    # Power key should not shut off computer by defaultPower key shuts of
    #services.logind.powerKey = "suspend";

    # Hyprland
    programs = {
      hyprland = {
        enable = true;
        xwayland.enable = true;
        withUWSM = true;
      };
    };
    environment.variables = {
    } // cfg.environmentVariables; 

    # Necessary packages
    environment.systemPackages = with pkgs; [
      jq
      fuzzel
      kitty
      waybar
    ];
    services.xserver = {
      enable = true;
    };

    # services.upower.enable = true;
    # Keyring
    services.gnome.gnome-keyring.enable = true;

    # Dbus
    services.dbus = {
      enable = true;
      packages = [ pkgs.dconf ];
    };

    programs.dconf.enable = true;

  };
}
