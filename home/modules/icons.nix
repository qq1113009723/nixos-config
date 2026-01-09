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
  
  # 光标主题常量（使用实际包中的主题名称）
  cursorThemes = {
    bibataModernIce = "Bibata-Modern-Ice";
    bibataModernClassic = "Bibata-Modern-Classic";
    bibataOriginalIce = "Bibata-Original-Ice";
    bibataOriginalClassic = "Bibata-Original-Classic";
    adwaita = "Adwaita";
    breeze = "Breeze";
    capitaine = "capitaine-cursors";
    vimix = "Vimix-cursors";
    phingerLight = "phinger-cursors-light";
    phingerDark = "phinger-cursors-dark";
    volantes = "volantes_cursors";
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
    };
  };

  config = lib.mkIf cfg.enable {
    # 图标主题包（根据选择动态安装）
    home.packages = with pkgs;[
      hicolor-icon-theme
    ]++
      # 根据选择的图标主题安装对应的包
      (lib.optionals (cfg.iconTheme == iconThemes.papirus) [ papirus-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.adwaita) [ adwaita-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.breeze) [ libsForQt5.breeze-icons ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.numix) [ numix-icon-theme-circle ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.arc) [ arc-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.tela) [ tela-icon-theme ]
      # 根据选择的光标主题安装对应的包，
      # lib.elem cfg.cursorTheme [...]：检查用户选择的光标主题是否在列表中，
      # 如果匹配，则安装 bibata-cursors 包
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
      ++ lib.optionals (lib.elem cfg.cursorTheme [
        cursorThemes.phingerLight
        cursorThemes.phingerDark
      ]) [ phinger-cursors ]
      ++ lib.optionals (cfg.cursorTheme == cursorThemes.volantes) [ volantes-cursors ]);

    # GTK 配置（用于 GTK2/GTK3/GTK4 应用）
    gtk = {
      enable = true;
      
      # 图标主题名称
      iconTheme = {
        name = cfg.iconTheme;
      };
      
      # 光标主题配置（这是 home-manager 中正确配置光标主题的方式）
      cursorTheme = {
        name = cfg.cursorTheme;
        size = cfg.cursorSize;
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
  };
}

