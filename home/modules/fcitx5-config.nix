{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.userSettings.fcitx5-config;
  
  # 根据输入法类型生成 profile 配置
  generateProfile = inputMethod: ''
    [Groups/0]
    Name=Default
    Default Layout=us
    DefaultIM=${inputMethod}

    [Groups/0/Items/0]
    Name=keyboard-us
    Layout=

    [Groups/0/Items/1]
    Name=${inputMethod}

    [GroupOrder]
    Size=1
    0=Default
  '';
in
{
  options = {
    userSettings.fcitx5-config = {
      enable = lib.mkEnableOption "Enable Fcitx5 input method configuration";
      
      inputMethod = lib.mkOption {
        type = lib.types.enum [ "rime" "pinyin" ];
        default = "rime";
        description = "Chinese input method to use. Options: rime (Rime输入法), pinyin (拼音)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      SDL_IM_MODULE = "fcitx";
      GLFW_IM_MODULE = "fcitx";
      ELECTRON_USE_WAYLAND = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    };

    xdg.configFile."fcitx5/profile" = {
      text = generateProfile cfg.inputMethod;
      force = true;
    };

    xdg.configFile."fcitx5/config" = {
      text = ''
        [Behavior]
        PreeditDelay=0
        DefaultPageSize=5
        UseWaylandIme=True
        # 强制使用 Wayland IME（对 Electron 应用很重要）
        ForceWaylandIme=False
        # 允许 fcitx5 处理全局快捷键
        AllowFcitx5ToHandleTheGlobalShortcut=True

        [Hotkey]
        ActivateKeys=Control+space
        DeactivateKeys=Shift_L+Shift_R

        [Addon]
        # 确保所有插件都启用
        EnabledAddons=

        [UI]
        # 托盘图标设置（Wayland 环境下）
        # 确保托盘图标可见（fcitx5 在 Wayland 下会自动使用 StatusNotifierItem 协议）
        TrayIcon=True
      '';
      force = true;
    };

    # Rime 输入法配置（仅在选择 rime 时生效）
    xdg.dataFile."fcitx5/rime/default.custom.yaml" = lib.mkIf (cfg.inputMethod == "rime") {
      text = ''
        patch:
          "menu/page_size": 5
          "preedit_format_delay": 0
      '';
      force = true;
    };
  };
}

