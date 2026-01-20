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
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        xwayland = {
          enable = true;
        };
        portalPackage = pkgs.xdg-desktop-portal-hyprland;
      };
    };

    # Keyring
    security.pam.services.login.enableGnomeKeyring = true;
    services.gnome.gnome-keyring.enable = true;
    programs.dconf.enable = true;
    # Dbus
    services.dbus = {
      enable = true;
      packages = [ pkgs.dconf ];
    };

    environment.systemPackages = with pkgs; [
      jq
      fuzzel
      kitty
    ];
    environment.variables = {
      # NIXOS_OZONE_WL = "1";
      # WLR_NO_HARDWARE_CURSORS = "1";
      # GSK_RENDERER = "gl";
    } // cfg.environmentVariables; 

    services.xserver = {
      enable = true;
    };
    
    xdg.portal = {
      enable = true;
    };

    systemSettings.shells = {
      enable = false;
      enabledShells = [ "noctalia" ];
    };


  };
}
