{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.systemSettings.vscode;
in
{
  options = {
    systemSettings.vscode = {
      enable = lib.mkEnableOption "Enable vscode";
    };
  };

  config = lib.mkIf cfg.enable{
    # 启用 virt-manager 程序
    # programs.vscode = {
    #   enable = true;
    #   package = pkgs.vscode.fhs;
    #   extensions = with pkgs.vscode-extensions; [
    #     jnoortheen.nix-ide
    #     asvetliakov.vscode-neovim
    #     vscjava.vscode-java-pack
    #     yzhang.markdown-all-in-one
    #   ];
    # };
    environment.systemPackages = with pkgs;[
      vscode
    ];
  };
}