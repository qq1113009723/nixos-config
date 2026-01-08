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
    cava
    fzf
    fastfetch
    nerd-fonts.jetbrains-mono
    btop
    cmatrix
    yazi
    fish
    wireguard-tools
  ];

}
