{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.systemSettings.kde;
in
{
  options = {
    systemSettings.kde = {
      enable = lib.mkEnableOption "Enable KDE Plasma desktop environment";

      # 选择 KDE 版本
      version = lib.mkOption {
        type = lib.types.enum [ "plasma6" ];
        default = "plasma6";
        description = "KDE Plasma version to use: plasma6 (Plasma 6)";
      };

      # 显示管理器配置
      displayManager = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable display manager for KDE";
        };

        type = lib.mkOption {
          type = lib.types.enum [ "sddm" "gdm" ];
          default = "sddm";
          description = "Display manager type: sddm (KDE default) or gdm";
        };
      };

      # 额外的系统包
      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Additional packages to install with KDE";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # 启用 X11/Wayland 服务器
    services.xserver.enable = true;

    # 配置显示管理器（使用新的选项路径）
    services.displayManager = lib.mkIf cfg.displayManager.enable {
      sddm = lib.mkIf (cfg.displayManager.type == "sddm") {
        enable = true;
      };
      gdm = lib.mkIf (cfg.displayManager.type == "gdm") {
        enable = true;
      };
      # 设置默认会话
      defaultSession = if cfg.version == "plasma6" then "plasma" else "plasma5";
    };

    # 启用 KDE Plasma 桌面环境（使用新的选项路径）
    services.desktopManager = {
      plasma6 = lib.mkIf (cfg.version == "plasma6") {
        enable = true;
      };
    };

    # KDE 相关的系统包
    # 注意：KDE 核心应用通常由桌面环境自动提供
    # 这里只添加常用的额外应用
    environment.systemPackages = cfg.extraPackages;

    # 环境变量配置
    environment.variables = {
      XDG_CURRENT_DESKTOP = if cfg.version == "plasma6" then "KDE" else "KDE";
    };

    # 启用必要的服务
    services = {
      # 蓝牙支持（可选）
      blueman.enable = false;
    };

    # 启用必要的程序
    programs = {
      # dconf 是 GNOME 的配置存储系统，KDE 不需要，但如果运行 GTK 应用可能需要
      # dconf.enable = true;  # 可选：如果运行 GTK 应用（如 Firefox、Chrome 等）可能需要
      # kdeconnect.enable = false;
    };
  };
}

