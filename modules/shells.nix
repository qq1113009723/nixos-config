{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.systemSettings.shells;
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

      # 可用的 shell 列表（通过设置 true/false 来控制启用）
      noctalia = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Noctalia shell (Wayland shell for Niri). Requires 'noctalia' input in flake.nix";
      };

      quickshell = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable QuickShell (Wayland shell). Requires 'quickshell' input in flake.nix";
      };

      dms-shell = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable DMS Shell (DankMaterialShell). Requires 'dms' input in flake.nix";
      };

      ags = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Aylur's Gtk Shell (AGS). Requires 'ags' input in flake.nix";
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
    # lib.optionals 说明：
    # - 如果 cfg.noctalia 为 true，则包含后面的列表 [inputs.noctalia...]
    # - 如果 cfg.noctalia 为 false，则返回空列表 []
    # - 这样可以根据配置动态决定是否安装某个 shell
    ++ lib.optionals cfg.noctalia [
      # Noctalia shell（需要从 inputs 获取）
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]
    ++ lib.optionals cfg.quickshell [
      # QuickShell（需要从 inputs 获取）
      inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]
    ++ lib.optionals (cfg.ags && inputs ? ags) [
      # AGS (Aylur's Gtk Shell)（如果通过 inputs 提供）
      inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]
    ++ cfg.extraShells;

    # DMS Shell (DankMaterialShell) - 通过 programs.dms-shell 配置
    # 说明：programs.dms-shell 是由 dms input 的 nixosModules 提供的选项
    # 当 cfg.dms-shell 为 true 时，启用 programs.dms-shell 并设置包路径
    # ? 是 Nix 的 hasAttr 操作符，用于检查属性是否存在 inputs ? dms 检查 inputs 是否包含 dms 属性
    programs.dms-shell = lib.mkIf (cfg.dms-shell && inputs ? dms) {
      enable = true;
      systemd.enable = true;
      package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
  };
}

