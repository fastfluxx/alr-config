{ config, pkgs, ... }:

{

  imports = [
    ./hyprland.nix
    ../../common/home-manager/ssh.nix
  ];
  # Home config
  home.username = "alr";
  home.homeDirectory = "/home/alr";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.



  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # Utils
    pkgs.screen
    pkgs.wget
    pkgs.htop
    pkgs.btop
    pkgs.tree
    pkgs.file
    pkgs.tldr
    pkgs.zip
    pkgs.p7zip
    pkgs.bat
    pkgs.dig
    pkgs.fastfetch
    pkgs.sshfs
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.font-awesome
    # Programming
    pkgs.python3
    # To enable copy-paste
    pkgs.wl-clipboard
    # VPN
    pkgs.wireguard-tools
    # Picture view
    pkgs.qimgv
    # Terminal File Manager
    pkgs.yazi
    # File transfer
    pkgs.filezilla
    # Password
    #pkgs.bitwarden-desktop
    # Network Analyze
    pkgs.tcpdump
    pkgs.nmap
    # Notes
    pkgs.obsidian
    # Video
    pkgs.vlc
    # Web Browser
    pkgs.firefox
    pkgs.ungoogled-chromium
    # Version control
    pkgs.git
    ## Rider stuff
    pkgs.kdePackages.kdenlive
    # Gaming
    pkgs.protonup-qt
    pkgs.winetricks
    pkgs.vulkan-tools
  ];



  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Configure programs

  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
    defaultEditor = true;

    initLua = ''
      vim.opt.number = true
      vim.opt.tabstop = 4
      vim.opt.softtabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.expandtab = true
    '';
  };



  programs.gpg = {
    enable = true;
  };


programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" "z" "sudo" "docker" ];
    };

    shellAliases = {
      cat = "bat -p";
      ssh = "TERM=xterm-256color ssh";
      vim = "nvim";
      nix-clean = "sudo nix-collect-garbage --delete-older-than 15d && sudo nixos-rebuild boot --flake .#alr-work";
    };

    history = {
      size = 10000;
    };

    initContent = ''
      zstyle :compinstall filename '~/.zshrc'

      autoload -Uz compinit
      compinit

      export PS1='%B%F{magenta}%K{magenta}%{█▓▒░%}%B%F{black}%K{magenta}%n@%m%b%F{black}%K{magenta}%{░▒%}%b%F{black}%K{blue}%{▒░%}%F{black}%K{blue}%~%F{black}%K{blue}%{░▒▓%}%k%B%F{white}
%}%B%F{green}%\-->%b%f '
    '';
  };


}
