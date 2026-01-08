{ config, pkgs, lib, ... }: {
  # 输入法配置（Fcitx5）- 系统级别配置
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      fcitx5
      qt6Packages.fcitx5-configtool
      fcitx5-nord
      fcitx5-rime  # Rime 输入法引擎
      rime-ice     # Rime-ICE 配置
    ];
    fcitx5.waylandFrontend = true;
  };
}

