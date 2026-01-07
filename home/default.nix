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
    git = {
      enable = true;
      useProxy = true;
      proxy = "http://192.168.106.171:7890";
    };
  };
}
