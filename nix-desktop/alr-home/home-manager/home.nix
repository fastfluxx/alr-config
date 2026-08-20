{ pkgs, ... }:

let
  # DOTNET_ROOT and the `dotnet` on PATH have to be the same tree; dotnet-sdk_10
  # is a different patch version from dotnetCorePackages.dotnet_10.sdk.
  dotnet = pkgs.dotnetCorePackages.dotnet_10.sdk;
in
{

  imports = [
    ./hyprland.nix
    ../../common/home-manager/base.nix
    ../../common/home-manager/ssh.nix
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${dotnet}/share/dotnet";
  };

  home.packages = [
    # Network analysis
    pkgs.wireshark
    # Remote desktop
    pkgs.remmina
    # SSH
    pkgs.openssl
    # IDE
    pkgs.jetbrains.rider
    ## Rider stuff
    pkgs.dotnet-ef
    pkgs.jetbrains.jdk
    dotnet
    # Android
    pkgs.android-tools
    # Video editing
    pkgs.kdePackages.kdenlive
  ];

}
