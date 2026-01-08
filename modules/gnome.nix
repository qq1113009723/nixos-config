{
  config,
  lib,
  pkgs,
  ...
}:
let 
  cfg = config.systemSettings.gnome;
in 
{
  options = {
    systemSettings.gnome = {
      enable = lib.mkEnableOption "Enable GNOME desktop environment";
      
      # 可选：是否启用 GDM（登录管理器）
      gdm = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable GDM display manager";
        };
      };
      
      # 注意：GNOME 默认使用 Wayland，如需 X11 可通过显示管理器选择 X11 会话
      
      # 可选：额外的系统包
      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Additional packages to install with GNOME";
      };
      
      # 可选：GNOME 扩展
      extensions = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "GNOME extensions to install";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # 启用 X11/Wayland 服务器
    services.xserver.enable = true;
    
    # 启用 GDM（登录管理器）
    services.displayManager.gdm.enable = cfg.gdm.enable;
    
    # 启用 GNOME 桌面环境（默认使用 Wayland）
    services.desktopManager.gnome.enable = true;
    
    # GNOME 相关的系统包
    environment.systemPackages = with pkgs; [
      # GNOME 核心组件（通常由 NixOS 自动提供）
      # 可以添加常用的 GNOME 应用
      gnome.gnome-tweaks
      gnome.gnome-terminal
      gnome.nautilus
      gnome.gnome-calculator
      gnome.gnome-system-monitor
    ] ++ cfg.extraPackages ++ cfg.extensions;
    
    # 环境变量配置
    environment.variables = {
      XDG_CURRENT_DESKTOP = "GNOME";
    };
    
    # 可选：GNOME 特定配置
    # programs.dconf.enable = true;  # 通常默认启用
  };
}

