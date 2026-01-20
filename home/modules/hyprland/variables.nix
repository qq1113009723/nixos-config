{ ... }:
{
  home.sessionVariables = {
    NIXOS_OZONE_WL = 1;
    DISABLE_QT5_COMPAT = 0;
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    QT_QPA_PLATFORMTHEME = "qt5ct";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    ELECTRON_USE_WAYLAND="1";
    GDK_BACKEND = "wayland,x11,*";
    QT_QPA_PLATFORM = "wayland;xcb";
    WLR_RENDERER_ALLOW_SOFTWARE = 1;
    MOZ_ENABLE_WAYLAND = 1;
    WLR_NO_HARDWARE_CURSORS = 1;
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    GRIMBLAST_HIDE_CURSOR = 0;
    EDITOR = "vim";
    VISUAL = "vim";
    SHELL = "fish";
    GTK_USE_PORTAL = "1";
  };
}