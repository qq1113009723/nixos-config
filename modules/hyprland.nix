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
    environment.variables = {
    } // cfg.environmentVariables; 

    # Necessary packages
    environment.systemPackages = with pkgs; [
      jq
      fuzzel
      kitty
      waybar
    ];
    
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
