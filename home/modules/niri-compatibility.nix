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
    # Niri Wayland 兼容配置
    # 这些环境变量确保应用在 Niri 下正确运行
    home.sessionVariables = 
      let
        # 获取光标主题配置（如果 icons 模块启用）
        cursorTheme = if (config.userSettings.icons.enable or false) 
          then config.userSettings.icons.cursorTheme
          else "Bibata-Modern-Ice";
        cursorSize = if (config.userSettings.icons.enable or false)
          then (toString config.userSettings.icons.cursorSize)
          else "24";
        
        # 获取截图目录（如果配置了）
        screenshotDir = if (config.xdg.userDirs.extraConfig or {} ? XDG_SCREENSHOT_DIR)
          then config.xdg.userDirs.extraConfig.XDG_SCREENSHOT_DIR
          else null;
      in
      {
        # --- 1. 强制 Wayland 支持 (通用) ---
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        XDG_SESSION_TYPE = "wayland";

        # --- 2. 桌面环境定义 (修改为 niri) ---
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_DESKTOP = "niri";

        # --- 3. 工具包后端配置 ---
        GDK_BACKEND = "wayland,x11,*";
        QT_QPA_PLATFORM = "wayland;xcb";
        
        # Niri 默认没有标题栏装饰，建议保留这个以防 QT 应用出现奇怪的边框
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        
        # 缩放倍率设置 (根据你的 4K 屏或个人喜好调整)
        QT_AUTO_SCREEN_SCALE_FACTOR = "1.25";

        # --- 4. 门户服务与集成 ---
        # Niri 建议配合 xdg-desktop-portal-gnome 使用，以获得最佳的屏幕共享支持
        GTK_USE_PORTALS = "1";
        
        # 光标主题 (引用图标模块的配置，如果启用的话)
        XCURSOR_THEME = cursorTheme;
        XCURSOR_SIZE = cursorSize;

        # 截图路径配置（如果 xdg.userDirs 配置了截图目录）
        # 注意：这需要 xdg.userDirs 模块配置了 XDG_SCREENSHOT_DIR
        # 如果未配置，则不设置此变量（使用默认的 ~/Pictures）
      }
      // lib.optionalAttrs (screenshotDir != null) {
        GRIM_DEFAULT_DIR = screenshotDir;
      }
      // {
        # --- 5. Niri 专用优化 ---
        # 某些应用在 Niri 滚动时可能会有同步问题，确保 SDL 应用也走 Wayland
        SDL_VIDEODRIVER = "wayland";
        # 强制部分 Java 应用不出现空白窗口 (AWT 相关)
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };
  };
}

