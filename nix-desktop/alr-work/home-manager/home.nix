{ pkgs, ... }:

let
  # DOTNET_ROOT and the `dotnet` on PATH have to be the same tree: pointing the
  # variable at a standalone dotnet-sdk_10 hid the 9 SDK from `dotnet --list-sdks`
  # (and was a different patch version of 10 besides).
  dotnet = pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnetCorePackages.dotnet_9.sdk
    pkgs.dotnetCorePackages.dotnet_10.sdk
  ];
in
{

  imports = [
    ./hyprland.nix
    ../../common/home-manager/base.nix
    ../../common/home-manager/ssh.nix
  ];

  # This host pins one identity for every connection, and reaches GitHub with
  # two FIDO2 tokens before the ordinary key. The sk keys go first so that a
  # touch is only ever asked for once ssh has run out of non-token options.
  local.ssh = {
    defaultIdentityFile = "~/.ssh/alr.priv";
    githubIdentityFiles = [
      "~/.ssh/id_ed25519_sk"
      "~/.ssh/id_ed25519_sk_02"
      "~/.ssh/alr.laud"
    ];
  };

  home.sessionVariables = {
    DOTNET_ROOT = "${dotnet}/share/dotnet";
  };

  services.network-manager-applet.enable = true;

  # The applet used to be a hand-written unit here, which set `Partof` instead
  # of `PartOf`; systemd ignored the typo'd key, so it was never stopped with
  # the session. The home-manager service does the same job correctly.
  services.blueman-applet.enable = true;

  home.packages = [
    # Network analysis
    pkgs.wireshark
    # Remote desktop
    pkgs.remmina
    # SSH
    pkgs.openssl
    pkgs.ssh-tools
    # IDE
    pkgs.jetbrains.rider
    ## Rider stuff
    pkgs.dotnet-ef
    pkgs.jetbrains.jdk
    dotnet
    # Android
    pkgs.android-tools
    # AI Code
    pkgs.claude-code
    pkgs.aider-chat
  ];

  # The switches below want ancient kex/cipher algorithms and are kept here
  # rather than in the shared module: they are reachable only from this host.
  #
  # programs.ssh.settings."sg220" = {
  #   HostName = "10.0.1.42";
  #   User = "cisco";
  #   KexAlgorithms = "+diffie-hellman-group1-sha1";
  #   HostKeyAlgorithms = "+ssh-rsa";
  #   Ciphers = "aes128-cbc,aes128-ctr,aes192-ctr,aes256-ctr";
  # };
  #
  # programs.ssh.settings."sg300" = { ... same, HostName = "10.0.1.41"; };

}
