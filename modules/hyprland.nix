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

    # Hyprland
    programs = {
      hyprland = {
        enable = true;
        xwayland.enable = true;
      };
    };
    programs.hyprlock.enable = true;
    services.hypridle.enable = true;

    environment.systemPackages = with pkgs; [
      pyprland
      hyprpicker
      hyprcursor
      hyprlock
      hypridle
      hyprpaper
      hyprsunset
      hyprpolkitagent
      fuzzel
      kitty
      foot
    ];
    environment.variables = {
      NIXOS_OZONE_WL = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
    } // cfg.environmentVariables; 

    
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
    };
    systemSettings.shells = {
      enable = true;
      enabledShells = [ "dms-shell" ];
    };


  };
}
