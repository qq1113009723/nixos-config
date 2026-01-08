{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.userSettings.fcitx5-config;
in
{
  options = {
    userSettings.fcitx5-config = {
      enable = lib.mkEnableOption "Enable Fcitx5 input method configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
    };

    xdg.configFile."fcitx5/profile" = {
      text = ''
        [Groups/0]
        Name=Default
        Default Layout=us
        DefaultIM=rime

        [Groups/0/Items/0]
        Name=keyboard-us
        Layout=

        [Groups/0/Items/1]
        Name=rime

        [GroupOrder]
        Size=1
        0=Default
      '';
      force = true;
    };

    xdg.configFile."fcitx5/config" = {
      text = ''
        [Behavior]
        PreeditDelay=0
        DefaultPageSize=5
        UseWaylandIme=True

        [Hotkey]
        ActivateKeys=Control+space
        DeactivateKeys=Shift_L+Shift_R
      '';
      force = true;
    };

    xdg.dataFile."fcitx5/rime/default.custom.yaml" = {
      text = ''
        patch:
          "menu/page_size": 5
          "preedit_format_delay": 0
      '';
      force = true;
    };
  };
}

