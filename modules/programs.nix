{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    home-manager
    vim
    wget
    git
    starship
    kitty
    fastfetch
    nerd-fonts.jetbrains-mono
    helix
    btop
    cmatrix
    yazi
    bat
    lsd
    fish
    wireguard-tools
    neovim
  ];

}
