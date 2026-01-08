{ username, ... }:

{
  home = {
    stateVersion = "25.11";
    username = username;
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
      proxy = "http://192.168.106.171:7890";
    };
    # 图标主题配置（home-manager 级别）
    icons = {
      enable = true;
      iconTheme = "Tela";  # 可选: Papirus, Adwaita, Breeze, Numix, Arc, Tela
      cursorTheme = "Bibata-Modern-Ice";
      cursorSize = 24;
      # installAllIconThemes = false;  # 设置为 true 可安装所有图标主题（用于预览和切换）
      # installAllCursorThemes = false;  # 设置为 true 可安装所有光标主题（用于预览和切换）
    };
  };
}
