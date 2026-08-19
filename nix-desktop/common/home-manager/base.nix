# The user environment shared by all three hosts: identity, the packages every
# machine has, and the three programs configured identically everywhere.
#
# Host files keep what actually differs -- IDEs and SDKs, gaming tools, the
# tray applets that only a laptop needs.
{ lib, pkgs, ... }:

{
  imports = [ ./git.nix ];

  home.username = "alr";
  home.homeDirectory = "/home/alr";

  # Home Manager's own compatibility marker. Set at first install and left
  # alone; see the Home Manager release notes before changing it.
  home.stateVersion = "24.05";

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.packages = with pkgs; [
    # Utils
    screen
    wget
    htop
    btop
    tree
    file
    tldr
    zip
    p7zip
    bat
    dig
    fastfetch
    sshfs
    nerd-fonts.jetbrains-mono
    font-awesome
    # Programming
    python3
    # To enable copy-paste
    wl-clipboard
    # VPN
    wireguard-tools
    # Picture view
    qimgv
    # Terminal file manager
    yazi
    # Notes
    obsidian
    # File transfer
    filezilla
    # Network analysis
    tcpdump
    nmap
    # Video
    vlc
    # Web browsers
    firefox
    ungoogled-chromium
    # Version control
    git
  ];

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

  programs.gpg.enable = true;

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;

    # alr-work and alr-home used to reach for this by sourcing
    # /usr/share/zsh-syntax-highlighting/..., which cannot exist on NixOS.
    # This is the option that actually does it, and it belongs on all three.
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      # No theme on purpose: initContent below exports PS1 by hand, and the
      # manual prompt wins regardless of what a theme sets. `agnoster` used to
      # be set here and did nothing.
      plugins = [ "git" "z" "sudo" "docker" ];
    };

    shellAliases = {
      cat = "bat -p";
      ssh = "TERM=xterm-256color ssh";
      vim = "nvim";
      nix-clean = "sudo nix-collect-garbage --delete-older-than 15d";
    };

    history = {
      size = 10000;
    };

    # autosuggestion.enable above already sources that plugin from the store.
    #
    # alr-work and alr-home used to end this with a conditional `source` of
    # /usr/share/zsh-syntax-highlighting/... -- dead on NixOS, where /usr holds
    # only `bin`. Dropped. Syntax highlighting comes from
    # programs.zsh.syntaxHighlighting.enable, which only alr-game sets.
    #
    # The order is pinned rather than left to chance. home-manager's ghostty
    # module also writes initContent, at the default order of 1000, and so did
    # this block while it lived in the host files -- the tie was broken by
    # module order, which moving it here would have flipped, putting the PS1
    # export before ghostty's shell integration instead of after it. 1050 sits
    # between ghostty at 1000 and the shell aliases at 1100, which is exactly
    # where this used to land.
    initContent = lib.mkOrder 1050 ''
      # Added by compinstall
      zstyle :compinstall filename '~/.zshrc'

      autoload -Uz compinit
      compinit

      # Theme preview: prompt -p
      export PS1='%B%F{magenta}%K{magenta}%{█▓▒░%}%B%F{black}%K{magenta}%n@%m%b%F{black}%K{magenta}%{░▒%}%b%F{black}%K{blue}%{▒░%}%F{black}%K{blue}%~%F{black}%K{blue}%{░▒▓%}%k%B%F{white}
%}%B%F{green}%\-->%b%f '
    '';
  };
}
