{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.systemSettings.firewall;
in
{
  options = {
    systemSettings.firewall = {
      enable = lib.mkEnableOption "Enable firewall and GUI tools";
      enableGUI = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable firewall GUI tools";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # 启用 nftables（firewalld 默认后端）
    networking.nftables.enable = true;

    # 启用 firewalld 服务（KDE 防火墙 GUI 需要）
    services.firewalld = {
      enable = true;
      # 使用 iptables 后端（如果不想使用 nftables）
      # settings.FirewallBackend = "iptables";
    };

    # 禁用 NixOS 默认防火墙，使用 firewalld 代替
    # 注意：firewalld 和 NixOS 防火墙不能同时启用
    networking.firewall.enable = false;

    # 安装防火墙 GUI 工具和管理工具
    environment.systemPackages = with pkgs; [
      firewalld-gui  # KDE 防火墙图形界面工具
      firewalld  # firewalld 命令行工具
      nmap  # 网络扫描工具
    ];
  };
}

