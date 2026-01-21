{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.userSettings.niri.compatibility;
in
{
  options = {
    userSettings.niri.compatibility = {
      enable = lib.mkEnableOption "Enable Niri compatibility configuration for user session";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      # xdgOpenUsePortal = true;
      extraPortals = [ 
        pkgs.xdg-desktop-portal-termfilechooser
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-cosmic
      ];
      config.common = {
        default = [  "cosmic" "gtk" "termfilechooser"];
        "org.freedesktop.impl.portal.FileChooser" = [ "cosmic" ];
      };
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = [ "com.system76.CosmicFiles.desktop" ];
        "x-scheme-handler/file" = [ "com.system76.CosmicFiles.desktop" ];
      };
      associations.added = {
        "inode/directory" = [ "com.system76.CosmicFiles.desktop" ];
      };
    };

    home.file.".config/xdg-desktop-portal-termfilechooser/config" = {
      text = ''
        [filechooser]
        # 这里的命令是你点击上传/保存时，系统要弹出的终端和命令
        # 假设你用 alacritty 和 yazi
        cmd=alacritty -e yazi --chooser-file=$path
      '';
    };

    
    # Niri Wayland 兼容配置
    # 这些环境变量确保应用在 Niri 下正确运行
    home.sessionVariables = 
      let
        cursorTheme = if (config.userSettings.icons.enable or false) 
          then config.userSettings.icons.cursorTheme
          else "Bibata-Modern-Ice";
        cursorSize = if (config.userSettings.icons.enable or false)
          then (toString config.userSettings.icons.cursorSize)
          else "24";
        
        screenshotDir = if (config.xdg.userDirs.extraConfig or {} ? XDG_SCREENSHOT_DIR)
          then config.xdg.userDirs.extraConfig.XDG_SCREENSHOT_DIR
          else null;
      in
      {

        GTK_USE_PORTAL = "1";
        # --- 1. 强制 Wayland 支持 (通用) ---
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        ELECTRON_USE_WAYLAND="1";
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_DESKTOP = "niri";
        GDK_BACKEND = "wayland,x11,*";
        QT_QPA_PLATFORM = "wayland;xcb";

        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        
        # QT_AUTO_SCREEN_SCALE_FACTOR: Qt 应用的自动缩放倍率
        # 根据你的 4K 屏或个人喜好调整（1.25 = 125% 缩放）
        QT_AUTO_SCREEN_SCALE_FACTOR = "1.25";
        GTK_USE_PORTALS = "1";
        XCURSOR_THEME = cursorTheme;
        XCURSOR_SIZE = cursorSize;
        SDL_VIDEODRIVER = "wayland";
        _JAVA_AWT_WM_NONREPARENTING = "1";
      }
      // lib.optionalAttrs (screenshotDir != null) {
        GRIM_DEFAULT_DIR = screenshotDir;
      };
  };
}

