{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.systemSettings.shells;
  
  # Shell 名称常量（避免硬编码字符串）
  shellNames = {
    noctalia = "noctalia";
    quickshell = "quickshell";
    dmsShell = "dms-shell";
    ags = "ags";
  };
  
  # 所有可用的 shell 列表（用于枚举类型）
  availableShells = [
    shellNames.noctalia
    shellNames.quickshell
    shellNames.dmsShell
    shellNames.ags
  ];
in
{
  options = {
    systemSettings.shells = {
      enable = lib.mkEnableOption "Enable shell management";

      # 注意：以下 shell 需要在 flake.nix 的 inputs 中定义：
      # - noctalia: github:noctalia-dev/noctalia-shell
      # - quickshell: github:outfoxxed/quickshell
      # - dms: github:AvengeMedia/DankMaterialShell (DMS Shell)
      # - ags: github:Aylur/ags

      # 启用的 shell 列表（可以多选）
      enabledShells = lib.mkOption {
        type = lib.types.listOf (lib.types.enum availableShells);
        default = [];
        description = ''
          List of shells to enable. Available options:
          - "${shellNames.noctalia}": Noctalia shell (Wayland shell for Niri). Requires 'noctalia' input in flake.nix
          - "${shellNames.quickshell}": QuickShell (Wayland shell). Requires 'quickshell' input in flake.nix
          - "${shellNames.dmsShell}": DMS Shell (DankMaterialShell). Requires 'dms' input in flake.nix
          - "${shellNames.ags}": Aylur's Gtk Shell (AGS). Requires 'ags' input in flake.nix
        '';
        example = [ shellNames.dmsShell shellNames.noctalia ];
      };

      # 额外的 shell 包
      extraShells = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Additional shell packages to install";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # 基础 shell 工具（始终安装）
    environment.systemPackages = with pkgs; [
      zsh   # Zsh shell
      bash  # Bash shell
    ]
    # 根据 enabledShells 列表动态安装相应的 shell
    ++ lib.optionals (lib.elem shellNames.noctalia cfg.enabledShells) [
      # Noctalia shell（需要从 inputs 获取）
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]
    ++ lib.optionals (lib.elem shellNames.quickshell cfg.enabledShells) [
      # QuickShell（需要从 inputs 获取）
      inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]
    ++ lib.optionals (lib.elem shellNames.ags cfg.enabledShells && inputs ? ags) [
      # AGS (Aylur's Gtk Shell)（如果通过 inputs 提供）
      inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]
    ++ cfg.extraShells
    # Wayland 系统托盘支持（当启用 dms-shell 时）
    # 安装系统托盘相关的包，用于显示应用图标（如 fcitx5、网络管理器等）
    ++ lib.optionals (lib.elem shellNames.dmsShell cfg.enabledShells) (with pkgs; [

    ]);

    # DMS Shell (DankMaterialShell) - 通过 programs.dms-shell 配置
    # 说明：programs.dms-shell 是由 dms input 的 nixosModules 提供的选项
    # 当 dms-shell 在 enabledShells 列表中时，启用 programs.dms-shell 并设置包路径
    # ? 是 Nix 的 hasAttr 操作符，用于检查属性是否存在 inputs ? dms 检查 inputs 是否包含 dms 属性
    programs.dms-shell = lib.mkIf (lib.elem shellNames.dmsShell cfg.enabledShells && inputs ? dms) {
      enable = true;
      systemd.enable = true;
      package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
  };
}

