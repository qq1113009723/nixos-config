{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    home-manager
    vim
    neovim
    wget
    git
    starship
    kitty
    fastfetch
    nerd-fonts.jetbrains-mono
    btop
    cava
    cmatrix
    yazi
    fish
    wireguard-tools
  ];

}
