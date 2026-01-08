{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let 
  cfg = config.systemSettings.niri;
in 
{
  options = {
    systemSettings.niri = {
      enable = lib.mkEnableOption "Enable Niri window manager with Noctalia shell";
      
      # 可选：是否启用显示管理器（Display Manager）
      displayManager = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable display manager for Niri session";
        };
        
        # 显示管理器类型（gdm, sddm, lightdm 等）
        type = lib.mkOption {
          type = lib.types.enum [ "gdm" "sddm" "lightdm" "none" ];
          default = "gdm";
          description = "Display manager type to use with Niri";
        };
      };
      
      # 额外的系统包
      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Additional packages to install with Niri";
      };
      
      # 环境变量配置
      environmentVariables = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          XCURSOR_THEME = "Bibata-Modern-Ice";
          XCURSOR_SIZE = "24";
        };
        description = "Environment variables for Niri session";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # 启用 Niri 窗口管理器
    programs.niri.enable = true;
    
    # 启用 Wayland（Niri 是 Wayland 合成器，不需要 X11）
    # 注意：如果同时使用其他需要 X11 的桌面环境，可能需要启用 xserver
    
    # 配置显示管理器
    # programs.niri.enable 会自动注册 Niri 会话到 display manager
    services.displayManager = lib.mkIf cfg.displayManager.enable {
      # 根据选择的显示管理器类型启用相应的服务
      gdm.enable = cfg.displayManager.type == "gdm";
      sddm.enable = cfg.displayManager.type == "sddm";
      lightdm.enable = cfg.displayManager.type == "lightdm";
      
      # 设置默认会话为 Niri（programs.niri.enable 会自动创建会话）
      defaultSession = lib.mkIf (cfg.displayManager.type != "none") "niri";
    };
    
    # Niri 和 Noctalia 相关的系统包
    environment.systemPackages = with pkgs; [
      # Niri 核心组件（由 programs.niri.enable 自动提供）
      
      # Noctalia shell
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      
      # Niri 常用工具
      fuzzel          # 应用启动器
      alacritty       # 终端
      bibata-cursors  # 光标主题
      xwayland-satellite  # XWayland 支持
      wl-clipboard    # Wayland 剪贴板工具
      xsel            # X11 剪贴板工具（兼容性）
      cliphist        # 剪贴板历史管理
      
      # 桌面门户（用于应用集成）
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ] ++ cfg.extraPackages;
    
    # 环境变量配置
    environment.variables = cfg.environmentVariables;
    
    # Wayland 相关配置
    # 确保 Wayland 会话可以正常运行
    security.polkit.enable = true;
    
    # 可选：如果需要 XWayland 支持（用于运行 X11 应用）
    programs.xwayland.enable = true;
  };
}
