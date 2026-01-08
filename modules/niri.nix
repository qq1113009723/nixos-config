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
        
        # 显示管理器类型（仅支持 GDM，因为 Niri 是 Wayland 合成器）
        type = lib.mkOption {
          type = lib.types.enum [ "gdm" "none" ];
          default = "gdm";
          description = "Display manager type to use with Niri (only GDM supports Wayland properly)";
        };
      };
      
      # 额外的系统包
      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Additional packages to install with Niri";
      };
      
      # 环境变量配置
      # 可以在这里添加额外的环境变量，默认值（XCURSOR_THEME 和 XCURSOR_SIZE）会自动包含
      environmentVariables = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Additional environment variables for Niri session. Default values (XCURSOR_THEME, XCURSOR_SIZE) are always included.";
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
    # 注意：Niri 是 Wayland 合成器，只支持 GDM（完全支持 Wayland）
    # SDDM 和 LightDM 主要支持 X11，无法正确启动 Wayland 会话
    services.displayManager = lib.mkIf (cfg.displayManager.enable && cfg.displayManager.type == "gdm") {
      # GDM 支持 Wayland，是唯一推荐的选择
      gdm.enable = true;
      
      # 设置默认会话为 Niri（programs.niri.enable 会自动创建会话）
      defaultSession = "niri";
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
      nautilus
      # 桌面门户（用于应用集成）
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ] ++ cfg.extraPackages;
    
    # 环境变量配置
    # 默认值（鼠标指针相关）+ 用户自定义的环境变量
    # 用户在 configuration.nix 中设置的环境变量会与默认值合并
    environment.variables = {
      # 默认环境变量
      XCURSOR_THEME = "Bibata-Modern-Ice";
      XCURSOR_SIZE = "24";
    } // cfg.environmentVariables;  # 用户自定义的环境变量会覆盖或添加到默认值
    
    # Wayland 相关配置
    # 确保 Wayland 会话可以正常运行
    systemSettings.polkit.enable = true;
    programs.xwayland.enable = true;
  };
}
