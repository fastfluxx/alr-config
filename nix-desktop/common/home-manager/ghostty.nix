{ ... }:

{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      "theme" = "Catppuccin Mocha";
      # Monaco is a macOS font and was never installed here, so Ghostty silently
      # fell back to its bundled default. This is the font the rest of the
      # desktop uses.
      "font-family" = "JetBrainsMono Nerd Font";
      "font-size" = 16;
    };
  };
}
