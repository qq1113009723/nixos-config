{ config, pkgs, ... }:

{

  # niri设置
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    fuzzel
    alacritty
    bibata-cursors
    xwayland-satellite
    wl-clipboard
    xsel
    cliphist
    xdg-desktop-portal-gnome   
    xdg-desktop-portal-gtk
];

  environment.variables = {
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";  
  };
}
