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
  };

  #virtualisation.vmware.guest.enable = true;

  # 桌面环境（根据下载的 ISO 启用一个）
  
  # KDE Plasma
  # services.desktopManager.plasma6.enable = true;

  # GNOME（GNOME ISO 用）
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # SSH 服务
  services.openssh.enable = true;

  # 系统版本（当前最新稳定版 25.11）
  system.stateVersion = "25.11";
}
