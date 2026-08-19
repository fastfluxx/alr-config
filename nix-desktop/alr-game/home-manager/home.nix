{ pkgs, ... }:

{

  imports = [
    ./hyprland.nix
    ../../common/home-manager/base.nix
    ../../common/home-manager/ssh.nix
  ];

  home.packages = [
    # Video editing
    pkgs.kdePackages.kdenlive
    # Gaming
    pkgs.protonup-qt
    pkgs.winetricks
    pkgs.vulkan-tools
  ];

}
