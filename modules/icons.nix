{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.systemSettings.icons;
  
  # 图标主题常量
  iconThemes = {
    papirus = "Papirus";
    adwaita = "Adwaita";
    breeze = "Breeze";
    numix = "Numix";
    tela = "Tela";
    zafiro = "Zafiro";
    fluent = "Fluent";
    colloid = "Colloid";
    qogir = "Qogir";
    whiteSur = "WhiteSur";
    arc = "Arc";
    mintX = "Mint-X";
    moka = "Moka";
    faba = "Faba";
    yaru = "Yaru";
    nordic = "Nordic";
    sweet = "Sweet";
    candy = "Candy";
    laCapitaine = "La-Capitaine";
    vibrancy = "Vibrancy";
    beautyLine = "BeautyLine";
    flatRemix = "Flat-Remix";
    obsidian = "Obsidian";
    elementary = "elementary";
  };
  
  # 光标主题常量
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
    systemSettings.icons = {
      enable = lib.mkEnableOption "Enable icon theme configuration";

      # 图标主题配置
      iconTheme = lib.mkOption {
        type = lib.types.enum (lib.attrValues iconThemes);
        default = iconThemes.papirus;
        description = ''
          Icon theme to use. Available options:
          - Papirus: Modern, flat icon theme (most popular)
          - Adwaita: GNOME default icon theme
          - Breeze: KDE default icon theme
          - Numix: Flat, modern icon theme
          - Tela: Flat icon theme with multiple color variants
          - Zafiro: Minimalist icon theme
          - Fluent: Microsoft Fluent Design inspired icons
          - Colloid: Modern, colorful icon theme
          - Qogir: Flat icon theme
          - WhiteSur: macOS Big Sur inspired icons
          - Arc: Flat icon theme
          - Mint-X: Linux Mint default icons
          - Moka: Flat icon theme
          - Faba: Flat icon theme
          - Yaru: Ubuntu default icon theme
          - Nordic: Dark icon theme
          - Sweet: Colorful icon theme
          - Candy: Colorful icon theme
          - La-Capitaine: macOS inspired icons
          - Vibrancy: Vibrant icon theme
          - BeautyLine: Beautiful line-style icons
          - Flat-Remix: Flat icon theme variants
          - Obsidian: Dark icon theme
          - elementary: elementary OS default icons
        '';
        example = iconThemes.papirus;
      };

      # 光标主题配置
      cursorTheme = lib.mkOption {
        type = lib.types.enum (lib.attrValues cursorThemes);
        default = cursorThemes.bibataModernIce;
        description = ''
          Cursor theme to use. Available options:
          - Bibata-Modern-Ice: Modern, animated cursor theme (ice variant)
          - Bibata-Modern-Classic: Modern, animated cursor theme (classic variant)
          - Bibata-Original-Ice: Original Bibata cursor theme (ice variant)
          - Bibata-Original-Classic: Original Bibata cursor theme (classic variant)
          - Adwaita: GNOME default cursor theme
          - Breeze: KDE default cursor theme
          - Capitaine Cursors: macOS inspired cursors
          - Vimix Cursors: Modern cursor theme
          - phinger-cursors: Minimalist cursor theme
          - Volantes Cursors: Modern cursor theme
          - macOS-BigSur: macOS Big Sur style cursors
          - macOS-Monterey: macOS Monterey style cursors
          - Sweet-cursors: Colorful cursor theme
        '';
        example = cursorThemes.bibataModernIce;
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
    environment.systemPackages = with pkgs;
      # 根据选择的图标主题安装对应的包
      (lib.optionals (cfg.iconTheme == iconThemes.papirus) [ papirus-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.adwaita) [ gnome.adwaita-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.breeze) [ breeze-icons ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.numix) [ numix-icon-theme-circle ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.tela) [ tela-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.zafiro) [ zafiro-icons ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.fluent) [ fluent-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.colloid) [ colloid-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.qogir) [ qogir-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.whiteSur) [ whitesur-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.arc) [ arc-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.mintX) [ mint-x-icons ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.moka) [ moka-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.faba) [ faba-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.yaru) [ yaru-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.nordic) [ nordic-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.sweet) [ sweet-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.candy) [ candy-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.laCapitaine) [ la-capitaine-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.vibrancy) [ vibrancy-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.beautyLine) [ beauty-line-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.flatRemix) [ flat-remix-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.obsidian) [ obsidian-icon-theme ]
      ++ lib.optionals (cfg.iconTheme == iconThemes.elementary) [ elementary-icon-theme ]
      # 如果启用，安装所有图标主题
      ++ lib.optionals cfg.installAllIconThemes [
        papirus-icon-theme
        gnome.adwaita-icon-theme
        breeze-icons
        numix-icon-theme-circle
        tela-icon-theme
        zafiro-icons
        fluent-icon-theme
        colloid-icon-theme
        qogir-icon-theme
        whitesur-icon-theme
        arc-icon-theme
        mint-x-icons
        moka-icon-theme
        faba-icon-theme
        yaru-theme
        nordic-icon-theme
        sweet-icon-theme
        candy-icon-theme
        la-capitaine-icon-theme
        vibrancy-icon-theme
        beauty-line-icon-theme
        flat-remix-icon-theme
        obsidian-icon-theme
        elementary-icon-theme
      ]
      # 根据选择的光标主题安装对应的包
      ++ lib.optionals (lib.elem cfg.cursorTheme [
        cursorThemes.bibataModernIce
        cursorThemes.bibataModernClassic
        cursorThemes.bibataOriginalIce
        cursorThemes.bibataOriginalClassic
      ]) [ bibata-cursors ]
      ++ lib.optionals (cfg.cursorTheme == cursorThemes.adwaita) [ gnome.adwaita-icon-theme ]
      ++ lib.optionals (cfg.cursorTheme == cursorThemes.breeze) [ breeze-icons ]
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

    # 环境变量配置（用于 GTK/QT 应用）
    environment.variables = {
      # 图标主题
      GTK_ICON_THEME_NAME = cfg.iconTheme;
      QT_ICON_THEME = cfg.iconTheme;
      # 光标主题
      XCURSOR_THEME = cfg.cursorTheme;
      XCURSOR_SIZE = toString cfg.cursorSize;
    };
  };
}

