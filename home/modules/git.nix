{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "zhoujinqiu";
      user.email = "1113009723@qq.com";
    };
  };
}
