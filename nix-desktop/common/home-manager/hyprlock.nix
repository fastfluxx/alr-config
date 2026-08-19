# Lock screen. Needs security.pam.services.hyprlock on the NixOS side.
{ config, lib, pkgs, ... }:

let
  cfg = config.local.hyprlock;
in
{
  options.local.hyprlock = {
    enable = lib.mkEnableOption "the shared hyprlock configuration";

    background = lib.mkOption {
      type = lib.types.path;
      default = ../../wallpaper/LM-Backgrop.png;
      description = ''
        Image shown behind the lock screen. Kept in the repo rather than in
        $HOME so that the SDDM greeter, which runs as the sddm user, can use
        the same file -- see common/nixos/sddm-hyprlock.nix.
      '';
    };
  };

  config.programs.hyprlock = lib.mkIf cfg.enable {
    enable = true;
    settings = {
      general = {
        disable_loading = true;
        grace = 0;
        no_fade_in = false;
      };

      background = [{
        monitor = ""; # Empty means all monitors
        path = toString cfg.background;
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
