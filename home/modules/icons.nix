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

  # 图标主题到包的映射函数
  # 函数定义：iconThemeToPackage :: String -> Package | null
  # 参数：theme - 图标主题名称（字符串）
  # 返回值：对应的 Nix 包，如果主题不存在则返回 null
  # 说明：
  # - `theme:` 是函数参数，使用 Nix 的 lambda 表达式语法（类似 λx. ...）
  # - `with pkgs;` 将 pkgs 的属性引入作用域，可以直接使用包名而不需要 pkgs.package-name
  # - 使用 if-else 链式判断主题名称，返回对应的包
  iconThemeToPackage = theme: with pkgs;
    if theme == iconThemes.papirus then papirus-icon-theme
    else if theme == iconThemes.adwaita then adwaita-icon-theme
    else if theme == iconThemes.breeze then libsForQt5.breeze-icons
    else if theme == iconThemes.numix then numix-icon-theme-circle
    else if theme == iconThemes.arc then arc-icon-theme
    else if theme == iconThemes.tela then tela-icon-theme
    else null;

  # 光标主题到包的映射函数
  # 函数定义：cursorThemeToPackage :: String -> Package | null
  # 参数：theme - 光标主题名称（字符串）
  # 返回值：对应的 Nix 包，如果主题不存在则返回 null
  #
  # 说明：
  # - `lib.elem theme [...]` 检查 theme 是否在列表中（类似 Python 的 `in` 操作符）
  # - 多个 Bibata 变体共享同一个 bibata-cursors 包
  # - phinger 的 light 和 dark 变体共享同一个 phinger-cursors 包
  cursorThemeToPackage = theme: with pkgs;
    if lib.elem theme [
      cursorThemes.bibataModernIce
      cursorThemes.bibataModernClassic
      cursorThemes.bibataOriginalIce
      cursorThemes.bibataOriginalClassic
    ] then bibata-cursors
    else if theme == cursorThemes.adwaita then adwaita-icon-theme
    else if theme == cursorThemes.breeze then libsForQt5.breeze-icons
    else if theme == cursorThemes.capitaine then capitaine-cursors
    else if theme == cursorThemes.vimix then vimix-cursors
    else if lib.elem theme [
      cursorThemes.phingerLight
      cursorThemes.phingerDark
    ] then phinger-cursors
    else if theme == cursorThemes.volantes then volantes-cursors
    else null;

  # 根据图标主题列表获取包列表的函数
  # 函数定义：getIconThemePackages :: [String] -> [Package]
  # 参数：themes - 图标主题名称列表
  # 返回值：对应的 Nix 包列表（过滤掉 null 值并去重）
  #
  # 说明：
  # - `map iconThemeToPackage themes` 将映射函数应用到列表的每个元素
  #   * map 是函数式编程中的高阶函数，类似 Python 的 map() 或 Haskell 的 map
  #   * 语法：map f [a, b, c] => [f(a), f(b), f(c)]
  # - `lib.filter (pkg: pkg != null) ...` 过滤掉 null 值
  #   * filter 是函数式编程中的高阶函数，类似 Python 的 filter()
  #   * `(pkg: pkg != null)` 是 lambda 表达式，判断包是否不为 null
  #   * 语法：filter pred [a, b, c] => 保留满足 pred 的元素
  # - `lib.unique` 去除列表中的重复元素（基于包路径）
  #   * 确保即使多个主题映射到同一个包，也只安装一次
  getIconThemePackages = themes:
    lib.unique (lib.filter (pkg: pkg != null) (map iconThemeToPackage themes));

  # 根据光标主题列表获取包列表的函数
  # 函数定义：getCursorThemePackages :: [String] -> [Package]
  # 参数：themes - 光标主题名称列表
  # 返回值：对应的 Nix 包列表（过滤掉 null 值并去重）
  #
  # 说明：与 getIconThemePackages 类似，但使用 cursorThemeToPackage 映射函数
  # - `lib.unique` 去除列表中的重复元素（基于包路径）
  #   * 例如：多个 Bibata 变体或 phinger 变体会映射到同一个包，去重避免重复安装
  getCursorThemePackages = themes:
    lib.unique (lib.filter (pkg: pkg != null) (map cursorThemeToPackage themes));
in
{
  options = {
    userSettings.icons = {
      enable = lib.mkEnableOption "Enable icon theme configuration for user";

      # 要安装的图标主题列表（可以安装多个）
      installedIconThemes = lib.mkOption {
        type = lib.types.listOf (lib.types.enum (lib.attrValues iconThemes));
        default = [ iconThemes.papirus ];
        description = "List of icon themes to install. Multiple themes can be installed, but only one can be applied.";
        example = [ iconThemes.papirus iconThemes.tela iconThemes.arc ];
      };

      # 要应用的图标主题（只能选择一个）
      iconTheme = lib.mkOption {
        type = lib.types.enum (lib.attrValues iconThemes);
        default = iconThemes.papirus;
        description = "Icon theme to apply (must be one of the installed themes)";
      };

      # 要安装的光标主题列表（可以安装多个）
      installedCursorThemes = lib.mkOption {
        type = lib.types.listOf (lib.types.enum (lib.attrValues cursorThemes));
        default = [ cursorThemes.bibataModernIce ];
        description = "List of cursor themes to install. Multiple themes can be installed, but only one can be applied.";
        example = [ cursorThemes.bibataModernIce cursorThemes.vimix cursorThemes.capitaine ];
      };

      # 要应用的光标主题（只能选择一个）
      cursorTheme = lib.mkOption {
        type = lib.types.enum (lib.attrValues cursorThemes);
        default = cursorThemes.bibataModernIce;
        description = "Cursor theme to apply (must be one of the installed themes)";
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
    # 基础包和主题包
    # 注意：某些图标主题包可能包含其他主题的文件，导致路径冲突
    # 如果遇到冲突（如 tela 和 papirus 都包含 breeze 图标），建议只安装不冲突的主题
    home.packages = with pkgs;
      # 基础图标主题（始终安装，作为后备）
      [ 
        hicolor-icon-theme
        adwaita-icon-theme
      ]
      # 根据 installedIconThemes 列表安装图标主题包（已去重）
      ++ getIconThemePackages cfg.installedIconThemes
      # 根据 installedCursorThemes 列表安装光标主题包（已去重）
      ++ getCursorThemePackages cfg.installedCursorThemes;

    # GTK 配置（用于 GTK2/GTK3/GTK4 应用）
    gtk = {
      enable = true;
      
      # 图标主题名称
      iconTheme = {
        name = cfg.iconTheme;
      };
      
      # 光标主题配置（这是 home-manager 中正确配置光标主题的方式）
      # 使用 mkDefault 允许其他模块（如 hyprland）覆盖此值
      cursorTheme = {
        name = cfg.cursorTheme;
        size = lib.mkDefault cfg.cursorSize;
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

