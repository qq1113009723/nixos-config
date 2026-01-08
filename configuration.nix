{ config, pkgs, hostname, inputs, ... }:

{
  imports = [ ./hardware-configuration.nix];

  # Bootloader（UEFI 默认）
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 主机名与网络
  networking.hostName = hostname;                  # 改成你喜欢的
  networking.networkmanager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # 时区与中文支持
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";
  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
    useXkbConfig = true;
  };

  # 国内加速（永久生效）
  nix.settings = {
   substituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"     # 中科大（可优先）
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"  # 清华
    "https://cache.nixos.org/"
   ];
   trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
   ];
  };

  # 普通用户（务必改用户名和初始密码）
  users.users.naraiu = {                            # ← 改成你的用户名
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  systemSettings = {
    vscode.enable = true;
    firefox.enable = true;
    vmware.guest.enable = true;
    firewall.enable = true;  # 启用防火墙 GUI 工具
    cosmic.enable = false;  # 启用 COSMIC 桌面环境
    gnome.enable = false;  # GNOME 桌面环境（通过 modules/gnome.nix 模块配置）
    kde = {
      enable = false;
      version = "plasma6";
    };

    niri = {
      enable = true;  # Niri 窗口管理器 + Noctalia shell（通过 modules/niri.nix 模块配置）
      displayManager = {
        enable = true;
        type = "gdm";  # 可选: "gdm", "none" (仅 GDM 支持 Wayland)
      };
      # 环境变量配置（会与默认值合并，默认包含 XCURSOR_THEME 和 XCURSOR_SIZE）
      environmentVariables = {
        EDITOR = "vim";
        VISUAL = "vim";
        SHELL = "fish";
        # 你可以在这里添加更多环境变量
        # 默认的 XCURSOR_THEME 和 XCURSOR_SIZE 会自动保留，除非你显式覆盖它们
      };
    };
  };

  #virtualisation.vmware.guest.enable = true;

  # 桌面环境（根据下载的 ISO 启用一个）
  # 桌面环境通过模块化配置，在 systemSettings 中启用：
  # - systemSettings.cosmic.enable = true   # COSMIC 桌面（modules/cosmic.nix）
  # - systemSettings.gnome.enable = true    # GNOME 桌面（modules/gnome.nix）
  # - systemSettings.niri.enable = true     # Niri + Noctalia（modules/niri.nix）
  # - KDE Plasma 等其他桌面环境可以类似地模块化

  # SSH 服务
  services.openssh.enable = true;

  # 系统版本（当前最新稳定版 25.11）
  system.stateVersion = "25.11";
}
