{ username, stateVersion, proxyDefault, ... }:

{
  home = {
    inherit stateVersion;
    inherit username;
    homeDirectory = "/home/${username}";
  };

  userSettings = {
    polkit.enable = true;
    code-cursor.enable = true;
    jetbrains.idea.enable = true;
    spotify.enable = true;
    fcitx5-config = {
      enable = true;
      inputMethod = "pinyin";  
    };
    git = {
      enable = true;
      useProxy = true;
      proxy =  proxyDefault;
    };
    # 图标主题配置（home-manager 级别）
    icons = {
      enable = true;
      # 要安装的图标主题列表（可以安装多个）
      # 注意：Tela 和 Papirus 都包含 breeze 图标文件，同时安装会导致路径冲突
      # 如果遇到冲突，建议只安装不冲突的主题组合
      installedIconThemes = [ "Tela" "Arc" ];  # 可选: Papirus, Adwaita, Breeze, Numix, Arc, Tela
      # 要应用的图标主题（只能选择一个，必须是已安装的主题之一）
      iconTheme = "Arc";
      # 要安装的光标主题列表（可以安装多个）
      installedCursorThemes = [ "Vimix-cursors" "Bibata-Modern-Ice" "capitaine-cursors" ];
      # 要应用的光标主题（只能选择一个，必须是已安装的主题之一）
      cursorTheme = "Vimix-cursors";  # 使用实际的主题名称
      cursorSize = 24;
    };
    # Niri Wayland 兼容配置
    niri.compatibility = {
      enable = true;  # 启用 Niri 兼容配置（Wayland 环境变量等）
    };
    clash-verge-rev.enable = false;
  };
}
