{ pkgs, ... }:

{
  # 1. Essential: Enable the PAM service so you can actually log back in
  # This part usually goes in your system-level configuration

  # 2. The Configuration
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading = true;
        grace = 0;
        no_fade_in = false;
      };

      background = [{
        monitor = ""; # Empty means all monitors
        path = "/home/alr/Pictures/Laud/LM-Backgrop.png";
        blur_passes = 1;
        color = "rgba(25, 20, 20, 1.0)";
      }];

      input-field = [{
        monitor = "";
        size = "250, 60";
        outline_thickness = 2;
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = true;
        outer_color = "rgba(0, 0, 0, 0)";
        inner_color = "rgba(0, 0, 0, 0.5)";
        font_color = "rgb(200, 200, 200)";
        fade_on_empty = true;
        placeholder_text = "<i>Password...</i>";
        hide_input = false;
        position = "0, -120";
        halign = "center";
        valign = "center";
      }];

      label = [
        {
          monitor = "";
          text = "$TIME";
          font_size = 120;
          font_family = "JetBrains Mono Nerd Font Bold";
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
