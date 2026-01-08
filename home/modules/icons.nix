{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.userSettings.icons;
  
  # 图标主题常量（最流行的几个）
  iconThemes = {
    papirus = "Papirus";      # 最流行的扁平图标主题
    adwaita = "Adwaita";      # GNOME 默认
    breeze = "Breeze";        # KDE 默认
    numix = "Numix";          # 流行的扁平主题
    arc = "Arc";              # 流行的扁平主题
    tela = "Tela";            # 流行的扁平主题
  };
  
  # 光标主题常量（与系统模块保持一致）
  cursorThemes = {
    bibataModernIce = "Bibata-Modern-Ice";
    bibataModernClassic = "Bibata-Modern-Classic";
    bibataOriginalIce = "Bibata-Original-Ice";
    bibataOriginalClassic = "Bibata-Original-Classic";
    adwaita = "Adwaita";
    breeze = "Breeze";
    capitaine = "Capitaine Cursors";
    vimix = "Vimix Cursors";
    phinger = "phinger-cursors";
    volantes = "Volantes Cursors";
    macosBigSur = "macOS-BigSur";
    macosMonterey = "macOS-Monterey";
    sweet = "Sweet-cursors";
  };
in
{
  options = {
    userSettings.icons = {
      enable = lib.mkEnableOption "Enable icon theme configuration for user";

      # 图标主题配置
      iconTheme = lib.mkOption {
        type = lib.types.enum (lib.attrValues iconThemes);
        default = iconThemes.papirus;
        description = "Icon theme to use";
      };

      # 光标主题配置
      cursorTheme = lib.mkOption {
        type = lib.types.enum (lib.attrValues cursorThemes);
        default = cursorThemes.bibataModernIce;
        description = "Cursor theme to use";
      };

      # 光标大小
      cursorSize = lib.mkOption {
        type = lib.types.int;
        default = 24;
        description = "Cursor size in pixels";
      };

      # 是否安装所有图标主题（用于预览和切换）
      installAllIconThemes = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install all available icon themes (useful for previewing and switching)";
      };

      # 是否安装所有光标主题（用于预览和切换）
      installAllCursorThemes = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install all available cursor themes (useful for previewing and switching)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # 图标主题包（根据选择动态安装）
    home.packages = with pkgs;
      # 根据选择的图标主题安装对应的包
      (lib.optionals (cfg.iconTheme == iconThemes.papirus) [ papirus-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.adwaita) [ adwaita-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.breeze) [ libsForQt5.breeze-icons ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.numix) [ numix-icon-theme-circle ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.arc) [ arc-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.tela) [ tela-icon-theme ]
      # 如果启用，安装所有图标主题
      ++ lib.optionals cfg.installAllIconThemes [
        papirus-icon-theme
        adwaita-icon-theme
        libsForQt5.breeze-icons
        numix-icon-theme-circle
        arc-icon-theme
        tela-icon-theme
      ]
      # 根据选择的光标主题安装对应的包
      ++ lib.optionals (lib.elem cfg.cursorTheme [
        cursorThemes.bibataModernIce
        cursorThemes.bibataModernClassic
        cursorThemes.bibataOriginalIce
        cursorThemes.bibataOriginalClassic
      ]) [ bibata-cursors ]
      ++ lib.optionals (cfg.cursorTheme == cursorThemes.adwaita) [ adwaita-icon-theme ]
      ++ lib.optionals (cfg.cursorTheme == cursorThemes.breeze) [ libsForQt5.breeze-icons ]
      ++ lib.optionals (cfg.cursorTheme == cursorThemes.capitaine) [ capitaine-cursors ]
      ++ lib.optionals (cfg.cursorTheme == cursorThemes.vimix) [ vimix-cursors ]
      ++ lib.optionals (cfg.cursorTheme == cursorThemes.phinger) [ phinger-cursors ]
      ++ lib.optionals (cfg.cursorTheme == cursorThemes.volantes) [ volantes-cursors ]
      ++ lib.optionals (lib.elem cfg.cursorTheme [
        cursorThemes.macosBigSur
        cursorThemes.macosMonterey
      ]) [ macos-cursors ]
      ++ lib.optionals (cfg.cursorTheme == cursorThemes.sweet) [ sweet-cursor-theme ]
      # 如果启用，安装所有光标主题
      ++ lib.optionals cfg.installAllCursorThemes [
        bibata-cursors
        capitaine-cursors
        vimix-cursors
        phinger-cursors
        volantes-cursors
        macos-cursors
        sweet-cursor-theme
      ]);

    # GTK 配置（用于 GTK2/GTK3/GTK4 应用）
    gtk = {
      enable = true;
      
      # 图标主题名称
      iconTheme = {
        name = cfg.iconTheme;
      };
    };

    # QT 配置（用于 QT5/QT6 应用）
    qt = {
      enable = true;
      
      # QT 样式主题（可选，用于统一外观）
      style = {
        name = "adwaita-dark";
        package = pkgs.adwaita-qt;
      };
    };

    # 环境变量配置（确保所有应用都能使用正确的图标和光标主题）
    home.sessionVariables = {
      # 图标主题
      GTK_ICON_THEME_NAME = cfg.iconTheme;
      QT_ICON_THEME = cfg.iconTheme;
      # 光标主题
      XCURSOR_THEME = cfg.cursorTheme;
      XCURSOR_SIZE = toString cfg.cursorSize;
    };

    # 通过 gsettings 设置 GTK 图标和光标主题（更可靠的方式）
    # 这会写入到 ~/.config/dconf/user
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        icon-theme = cfg.iconTheme;
        cursor-theme = cfg.cursorTheme;
        cursor-size = cfg.cursorSize;
      };
    };

    # GTK3 配置文件（直接写入，确保兼容性）
    xdg.configFile."gtk-3.0/settings.ini" = {
      text = ''
        [Settings]
        gtk-icon-theme-name=${cfg.iconTheme}
        gtk-cursor-theme-name=${cfg.cursorTheme}
        gtk-cursor-theme-size=${toString cfg.cursorSize}
      '';
      force = true;
    };

    # GTK4 配置文件
    xdg.configFile."gtk-4.0/settings.ini" = {
      text = ''
        [Settings]
        gtk-icon-theme-name=${cfg.iconTheme}
        gtk-cursor-theme-name=${cfg.cursorTheme}
        gtk-cursor-theme-size=${toString cfg.cursorSize}
      '';
      force = true;
    };

    # 注意：.gtkrc-2.0 文件由 gtk.enable = true 自动生成
    # GTK 模块会自动使用我们配置的 iconTheme，所以不需要手动管理
  };
}

