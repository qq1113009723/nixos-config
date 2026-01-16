{
  config,
  lib,
  pkgs,
  system,
  ...
}:
let 
  cfg = config.userSettings.spotify;
  spotifyPackage = builtins.tryEval pkgs.spotify;
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
    warnings = lib.optionals (!spotifyPackage.success || spotifyPackage.value == null) [
      "Spotify is not available on architecture '${system}'. Supported architectures include x86_64-linux."
    ];
  };

}