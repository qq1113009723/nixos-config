{ config,lib,pkgs,inputs, system, ... }:

{
  options = {
    userSettings.code-cursor = {
      enable = lib.mkEnableOption "Enable code-cursor";
    };
  };
  config = lib.mkIf config.userSettings.code-cursor.enable {
    home.packages = [
      pkgs.code-cursor
    ];

    # 为 Cursor 创建启动脚本，确保输入法环境变量正确设置
    # Cursor 是 Electron 应用，需要特殊的环境变量配置
    # home.file.".local/bin/cursor" = {
    #   executable = true;
    #   text = ''
    #     #!/usr/bin/env bash
    #     # Cursor 启动脚本，确保输入法环境变量正确设置
    #     export GTK_IM_MODULE=fcitx
    #     export QT_IM_MODULE=fcitx
    #     export XMODIFIERS=@im=fcitx
    #     export SDL_IM_MODULE=fcitx
    #     export GLFW_IM_MODULE=fcitx
    #     export ELECTRON_USE_WAYLAND=1
    #     export ELECTRON_OZONE_PLATFORM_HINT=wayland
        
    #     # 启动 Cursor
    #     exec ${pkgs.code-cursor}/bin/cursor "$@"
    #   '';
    # };
  };

}
