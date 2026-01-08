{
  config,
  lib,
  pkgs,
  ...
}:
let 
  cfg = config.systemSettings.cosmic;
in 
{
  options = {
    systemSettings.cosmic = {
      enable = lib.mkEnableOption "Enable COSMIC desktop environment";
      
      # 可选：是否启用 Cosmic Greeter（登录管理器）
      greeter = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable COSMIC Greeter display manager";
        };
      };
      
      # 可选：额外的系统包
      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Additional packages to install with COSMIC";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # 启用 X11/Wayland 服务器
    services.xserver.enable = true;
    
    # 启用 COSMIC 桌面环境
    services.desktopManager.cosmic.enable = true;
    
    # 启用 COSMIC Greeter（登录管理器）
    services.displayManager.cosmic-greeter.enable = cfg.greeter.enable;
    
    # 如果禁用了 greeter，可以回退到其他显示管理器
    # services.displayManager.gdm.enable = !cfg.greeter.enable;
    
    # COSMIC 相关的系统包
    environment.systemPackages = with pkgs; [
      # COSMIC 核心组件（通常由 nixos-cosmic 模块自动提供）
      # 这里可以添加额外的 COSMIC 相关工具
    ] ++ cfg.extraPackages;
    
    # 环境变量配置（可选）
    environment.variables = {
      # 如果需要特定的环境变量，可以在这里添加
      # XDG_CURRENT_DESKTOP = "COSMIC";
    };
  };
}

