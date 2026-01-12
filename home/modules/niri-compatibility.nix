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
    # 
    # 注意：环境变量通过 home-manager 的 sessionVariables 设置，
    # 保存在 ~/.nix-profile/etc/profile.d/hm-session-vars.sh 中
    # 需要重新登录或重新加载 shell 配置才能在当前会话中生效
    # 验证方法：cat ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    home.sessionVariables = 
      let
        # 获取光标主题配置（如果 icons 模块启用）
        # 如果 icons 模块未启用，使用默认值
        cursorTheme = if (config.userSettings.icons.enable or false) 
          then config.userSettings.icons.cursorTheme
          else "Bibata-Modern-Ice";
        cursorSize = if (config.userSettings.icons.enable or false)
          then (toString config.userSettings.icons.cursorSize)
          else "24";
        
        # 获取截图目录（如果配置了 xdg.userDirs.extraConfig.XDG_SCREENSHOT_DIR）
        # 如果未配置，返回 null，GRIM_DEFAULT_DIR 将不会被设置（使用默认的 ~/Pictures）
        screenshotDir = if (config.xdg.userDirs.extraConfig or {} ? XDG_SCREENSHOT_DIR)
          then config.xdg.userDirs.extraConfig.XDG_SCREENSHOT_DIR
          else null;
      in
      {
        # --- 1. 强制 Wayland 支持 (通用) ---
        # NIXOS_OZONE_WL: 启用 NixOS 的 Ozone Wayland 支持（用于 Electron/Chromium 应用）
        NIXOS_OZONE_WL = "1";
        # ELECTRON_OZONE_PLATFORM_HINT: 告诉 Electron 应用使用 Wayland 后端
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        ELECTRON_USE_WAYLAND="1";
        # XDG_SESSION_TYPE: 标识当前会话类型为 Wayland
        XDG_SESSION_TYPE = "wayland";

        # --- 2. 桌面环境定义 ---
        # XDG_CURRENT_DESKTOP: 标识当前桌面环境为 niri（用于应用检测桌面环境）
        XDG_CURRENT_DESKTOP = "niri";
        # XDG_SESSION_DESKTOP: 标识当前会话的桌面环境为 niri
        XDG_SESSION_DESKTOP = "niri";

        # --- 3. 工具包后端配置 ---
        # GDK_BACKEND: GTK 应用的后端优先级（wayland > x11 > *）
        # 应用会按顺序尝试，优先使用 Wayland，失败时回退到 X11
        GDK_BACKEND = "wayland,x11,*";
        # QT_QPA_PLATFORM: Qt 应用的后端优先级（wayland > xcb）
        # 应用会按顺序尝试，优先使用 Wayland，失败时回退到 X11
        QT_QPA_PLATFORM = "wayland;xcb";
        
        # QT_WAYLAND_DISABLE_WINDOWDECORATION: 禁用 Qt 应用的窗口装饰
        # Niri 默认没有标题栏装饰，建议保留这个以防 QT 应用出现奇怪的边框
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        
        # QT_AUTO_SCREEN_SCALE_FACTOR: Qt 应用的自动缩放倍率
        # 根据你的 4K 屏或个人喜好调整（1.25 = 125% 缩放）
        QT_AUTO_SCREEN_SCALE_FACTOR = "1.25";

        # --- 4. 门户服务与集成 ---
        # GTK_USE_PORTALS: 启用 GTK 应用的桌面门户支持
        # Niri 建议配合 xdg-desktop-portal-gnome 使用，以获得最佳的屏幕共享支持
        GTK_USE_PORTALS = "1";
        
        # --- 5. 光标主题配置 ---
        # XCURSOR_THEME: 光标主题名称（引用图标模块的配置，如果启用的话）
        # 如果 icons 模块未启用，使用默认值 "Bibata-Modern-Ice"
        XCURSOR_THEME = cursorTheme;
        # XCURSOR_SIZE: 光标大小（像素）
        # 如果 icons 模块未启用，使用默认值 24
        XCURSOR_SIZE = cursorSize;

        # --- 6. Niri 专用优化 ---
        # SDL_VIDEODRIVER: SDL 应用的视频驱动
        # 某些应用在 Niri 滚动时可能会有同步问题，确保 SDL 应用也走 Wayland
        SDL_VIDEODRIVER = "wayland";
        # _JAVA_AWT_WM_NONREPARENTING: Java AWT 窗口管理器设置
        # 强制部分 Java 应用不出现空白窗口（AWT 相关）
        _JAVA_AWT_WM_NONREPARENTING = "1";
      }
      // lib.optionalAttrs (screenshotDir != null) {
        # GRIM_DEFAULT_DIR: grim 截图工具的默认保存目录
        # 只有在配置了 xdg.userDirs.extraConfig.XDG_SCREENSHOT_DIR 时才会设置
        # 如果未配置，则不设置此变量（使用默认的 ~/Pictures）
        GRIM_DEFAULT_DIR = screenshotDir;
      };
  };
}

