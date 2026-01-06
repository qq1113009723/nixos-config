{ pkgs, ... }:

{
  programs.git = {
    enable = false;
    settings = {
      user.name = "zhoujinqiu";
      user.email = "1113009723@qq.com";
      https.proxy = "http://192.168.106.171:7890";
    };
  };
}
