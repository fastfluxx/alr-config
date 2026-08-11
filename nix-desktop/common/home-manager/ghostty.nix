{ ... }:

{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      "theme" = "Catppuccin Mocha";
      "font-family" = "Monaco";
      "font-size" = 16;
    };
  };
}
