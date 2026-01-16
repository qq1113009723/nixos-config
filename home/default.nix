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
    jetbrains.idea.enable = false;
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
    icons = {
      enable = true;
      installedIconThemes = [ "Tela" "Arc" ];  # 可选: Papirus, Adwaita, Breeze, Numix, Arc, Tela
      iconTheme = "Arc";
      installedCursorThemes = [ "Vimix-cursors" "Bibata-Modern-Ice" "capitaine-cursors" ];
      cursorTheme = "Vimix-cursors";  # 使用实际的主题名称
      cursorSize = 24;
    };
    niri.compatibility = {
      enable = false;  # 启用 Niri 兼容配置（Wayland 环境变量等）
    };
    clash-verge-rev.enable = false;
  };
}
