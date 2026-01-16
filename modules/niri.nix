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

    services.displayManager = lib.mkIf (cfg.displayManager.enable && cfg.displayManager.type == "gdm") {
      gdm.enable = true;
      defaultSession = "niri";
    };
    
    environment.systemPackages = with pkgs; [
      fuzzel          # 应用启动器
      alacritty       # 终端
      bibata-cursors  # 光标主题
      xwayland-satellite  # XWayland 支持
      wl-clipboard    # Wayland 剪贴板工具
      xsel            # X11 剪贴板工具（兼容性）
      cliphist        # 剪贴板历史管理
      kdePackages.dolphin # 文件管理器
      # 桌面门户（用于应用集成）
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ] ++ cfg.extraPackages;
    
    # 环境变量配置
    environment.variables = {
      XDG_SESSION_TYPE = "wayland";
    } // cfg.environmentVariables;  # 用户自定义的环境变量会覆盖或添加到默认值
    
    systemSettings.shells = {
      enable = true;    
      enabledShells = [ "noctalia" ]; 
    };
  };
}
