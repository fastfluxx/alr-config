{ pkgs, ... }:

{

  imports = [
    ./hyprland.nix
    ../../common/home-manager/base.nix
    ../../common/home-manager/ssh.nix
  ];

  # alr-work and alr-home get none: their initContent used to source the
  # plugin from /usr/share, which does not exist on NixOS.
  programs.zsh.syntaxHighlighting.enable = true;

  home.packages = [
    # Video editing
    pkgs.kdePackages.kdenlive
    # Gaming
    pkgs.protonup-qt
    pkgs.winetricks
    pkgs.vulkan-tools
  ];

}
