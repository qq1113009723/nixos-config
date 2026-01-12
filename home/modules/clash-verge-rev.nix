{
  config,
  lib,
  pkgs,
  unfreePkgs,
  system,
  ...
}:
let
  cfg = config.userSettings.clash-verge-rev;

  # 尝试从 nixpkgs 获取 Clash Verge 包
  # 首先尝试从 unfreePkgs 获取（如果存在）
  clashVergeFromUnfree = builtins.tryEval (
    if builtins.hasAttr "clash-verge-rev" unfreePkgs then
      unfreePkgs.clash-verge-rev
    else
      null
  );

  # 尝试从 pkgs 获取（如果存在）
  clashVergeFromPkgs = builtins.tryEval (
    if builtins.hasAttr "clash-verge-rev" pkgs then
      pkgs.clash-verge-rev
    else
      null
  );

  # 选择可用的包（优先级：unfreePkgs > pkgs）
  clashVergePackage = 
    if clashVergeFromUnfree.success && clashVergeFromUnfree.value != null then
      clashVergeFromUnfree.value
    else if clashVergeFromPkgs.success && clashVergeFromPkgs.value != null then
      clashVergeFromPkgs.value
    else
      null;

  # 检查包是否可用
  clashVergeAvailable = clashVergePackage != null;
in
{
  options = {
    userSettings.clash-verge-rev = {
      enable = lib.mkEnableOption "Enable Clash Verge (a graphical user interface for Clash)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optionals clashVergeAvailable [
      clashVergePackage
    ];

    # 如果启用了但包不可用，输出警告信息
    warnings = lib.optionals (!clashVergeAvailable) [
      "Clash Verge is not available in nixpkgs. Please check if 'clash-verge' package exists, or consider using 'nix profile add' to install it manually."
    ];
  };
}

