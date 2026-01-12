{
  config,
  lib,
  pkgs,
  unfreePkgs,
  system,
  ...
}:
let 
  cfg = config.userSettings.spotify;
  
  # 检查 Spotify 是否在当前架构上可用
  # 使用 tryEval 安全地尝试访问包，如果包不存在或不可用则返回 null
  # tryEval 会捕获评估错误，返回 { success = true/false; value = ... }
  spotifyPackage = builtins.tryEval unfreePkgs.spotify;
  
  # 只在包可用时返回包，否则返回空列表
  # 注意：Spotify 主要支持 x86_64-linux，aarch64-linux 等架构可能不支持
  spotifyPackages = lib.optionals (spotifyPackage.success && spotifyPackage.value != null) [
    spotifyPackage.value
  ];
in
{
  options = {
    userSettings.spotify = {
      enable = lib.mkEnableOption "Enable spotify (only available on supported architectures like x86_64-linux)";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = spotifyPackages;
    
    # 如果启用了但包不可用，输出警告信息
    warnings = lib.optionals (!spotifyPackage.success || spotifyPackage.value == null) [
      "Spotify is not available on architecture '${system}'. Supported architectures include x86_64-linux."
    ];
  };

}