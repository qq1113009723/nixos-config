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
    jetbrains.idea-ultimate.enable = true;
  };
}
