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
      cursorTheme = "Vimix-cursors";  # 使用实际的主题名称
      cursorSize = 24;
    };
  };
}
