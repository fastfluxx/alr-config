{ config, pkgs, ... }:

{

  imports = [
    ./hyprland.nix
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

  nixpkgs.config = {
  	allowUnfree = true;
  };



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
	pkgs.bitwarden-desktop
	# Network Analyze
	pkgs.tcpdump
	pkgs.nmap
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


  programs.ssh = {
    enable = true;

    enableDefaultConfig = false; 
    


	matchBlocks = {
      	# Block 1: A general block for all hosts (*)
      	# You must define this if you set enableDefaultConfig = false
      	"*" = {
        # Common options for all connections
        # The value must be a string, or true/false for boolean options.
        user = config.home.username; # Default user for all hosts
        serverAliveInterval = 60;
      	};

      # Block 2: Specific configuration for a remote server
      	"github.com" = {
        	hostname = "github.com";
        	user = "git";
        	identityFile = [ "~/.ssh/alr.priv" ]; # Specific key for GitHub
        	identitiesOnly = true; # Only use the key specified above
      	};


  };

};

programs.zsh = {

        enable = true;
        autosuggestion.enable = true;


        oh-my-zsh = {
          enable = true;
          theme = "agnoster";  
          plugins = [ "git" "z" "sudo" "docker" ];
    	};

        shellAliases = {
            cat="bat -p";
            ssh="TERM=xterm-256color ssh";
	        vim="nvim";

            # Toggle Air-Gap ON
            gap-on  = "sudo /run/current-system/specialisation/airgap/bin/switch-to-configuration test";
    
            # Toggle Air-Gap OFF (Returns to the main system config)
            gap-off = "sudo /run/current-system/bin/switch-to-configuration test";
    
            # Check if we are currently in the airgap specialisation
            gap-status = "grep -q 'air-gapped' /run/current-system/kernel-params && echo 'Air-Gap: ON' || echo 'Air-Gap: OFF'";
        };


        history = {
            size = 10000;
        };

        initContent = 
        "
          # Check if zsh-autosuggestions script is not downloaded
          if [[ ! -f ~/.zsh/zsh-autosuggestions.zsh ]]; then
          # Download zsh-autosuggestions script
          mkdir -p ~/.zsh
          curl -o ~/.zsh/zsh-autosuggestions.zsh https://raw.githubusercontent.com/zsh-users/zsh-autosuggestions/master/zsh-autosuggestions.zsh
          fi
 
        # Source zsh-autosuggestions script
        source ~/.zsh/zsh-autosuggestions.zsh
 
 
        # The following lines were added by compinstall
        zstyle :compinstall filename '~/.zshrc'
 
        autoload -Uz compinit 
        compinit
 
 
      # Theme (preview: prompt -p)
      #prompt fire red magenta blue black white red
 
      export PS1='%B%F{magenta}%K{magenta}%{█▓▒░%}%B%F{black}%K{magenta}%n@%m%b%F{black}%K{magenta}%{░▒%}%b%F{black}%K{blue}%{▒░%}%F{black}%K{blue}%~%F{black}%K{blue}%{░▒▓%}%k%B%F{white} 
%}%B%F{green}%\-->%b%f '


      # Keep at the bottom
      if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
               source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      fi
        ";



      };



  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
