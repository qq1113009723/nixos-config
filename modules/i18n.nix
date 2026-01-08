{ config, pkgs, lib, ... }:
let
  # Locale 常量（避免硬编码字符串）
  locales = {
    zhCN = "zh_CN.UTF-8";
    enUS = "en_US.UTF-8";
  };
  
  # 支持的 locale 列表（完整格式，用于 supportedLocales）
  supportedLocalesList = [
    "${locales.zhCN}/UTF-8"
    "${locales.enUS}/UTF-8"
  ];
in
{
  # 国际化/本地化配置
  i18n = {
    defaultLocale = locales.zhCN;
    extraLocaleSettings = {
      LC_ADDRESS = locales.zhCN;
      LC_IDENTIFICATION = locales.zhCN;
      LC_MEASUREMENT = locales.zhCN;
      LC_MONETARY = locales.zhCN;
      LC_NAME = locales.zhCN;
      LC_NUMERIC = locales.zhCN;
      LC_PAPER = locales.zhCN;
      LC_TELEPHONE = locales.zhCN;
      LC_TIME = locales.zhCN;
    };
    supportedLocales = supportedLocalesList;
  };
}

