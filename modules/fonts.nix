{ config, pkgs, lib, ... }: {
  # 字体配置
  fonts = {
    packages = with pkgs; [
      cascadia-code
      noto-fonts
      noto-fonts-cjk-sans    # 思源黑体 (无衬线)
      noto-fonts-cjk-serif   # 思源宋体 (衬线)
      nerd-fonts.jetbrains-mono  # JetBrainsMono Nerd Font (用于终端)
    ];
    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Noto Sans CJK SC" ];
        serif = [ "Noto Serif CJK SC" ];
        monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono CJK SC" ];
      };
    };
  };
}

