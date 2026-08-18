# SDDM greeter themed to match hyprlock, so the login screen and the lock
# screen look like the same thing. The greeter runs as the sddm user in its own
# session, so everything it needs -- the background included -- has to come
# from the store rather than from $HOME.
#
# The look itself lives in ./sddm-hyprlock/Main.qml, which mirrors the values
# in common/home-manager/hyprlock.nix.
{ config, lib, pkgs, ... }:

let
  cfg = config.local.sddmTheme;

  # The greeter binary SDDM will reach for, resolved the way SDDM resolves it:
  # QtVersion in metadata.desktop, defaulting to 5, where 5 means a bare
  # `sddm-greeter` and anything else appends `-qt<n>`.
  sddmPackage = config.services.displayManager.sddm.package;

  theme = pkgs.runCommand "sddm-theme-hyprlock"
    {
      nativeBuildInputs = [ pkgs.imagemagick pkgs.qt6.qtdeclarative ];
    }
    ''
      # A broken theme leaves the greeter as a black screen with no way to log
      # in, so parse the QML here instead of finding out at the login prompt.
      # qmllint fails on syntax errors and only warns about the context
      # properties SDDM injects (sddm, userModel, sessionModel).
      qmllint ${./sddm-hyprlock/Main.qml}

      # A theme whose QtVersion names a greeter that was never built does not
      # fail anything -- SDDM logs one line and quietly serves the stock
      # fallback theme, which is indistinguishable from the theme never having
      # been applied at all. nixpkgs builds only the qt6 greeter, so pin the
      # two together here where a mismatch is a build error.
      qtVersion=$(sed -n 's/^QtVersion=//p' ${./sddm-hyprlock/metadata.desktop})
      case "''${qtVersion:-5}" in
        5) greeter=${sddmPackage}/bin/sddm-greeter ;;
        *) greeter=${sddmPackage}/bin/sddm-greeter-qt''${qtVersion} ;;
      esac
      if [ ! -x "$greeter" ]; then
        echo "metadata.desktop QtVersion=''${qtVersion:-5 (default)} selects $greeter," >&2
        echo "which ${sddmPackage} does not provide. The greeter would fall back" >&2
        echo "to the stock theme. Available:" >&2
        ls ${sddmPackage}/bin >&2
        exit 1
      fi

      dir="$out/share/sddm/themes/hyprlock"
      mkdir -p "$dir"
      cp ${./sddm-hyprlock/Main.qml} "$dir/Main.qml"
      cp ${./sddm-hyprlock/metadata.desktop} "$dir/metadata.desktop"

      # hyprlock blurs the background itself (blur_passes = 1). The image is
      # static, so bake the blur in rather than running a shader on the login
      # path -- one less thing that can fail with nothing else on screen.
      magick ${cfg.background} -blur 0x${toString cfg.blurSigma} "$dir/background.png"
    '';
in
{
  options.local.sddmTheme = {
    enable = lib.mkEnableOption "the hyprlock-styled SDDM theme";

    background = lib.mkOption {
      type = lib.types.path;
      default = ../../wallpaper/LM-Backgrop.png;
      description = "Image behind the greeter. Same one hyprlock uses.";
    };

    blurSigma = lib.mkOption {
      type = lib.types.int;
      default = 5;
      description = ''
        Gaussian sigma baked into the background, approximating hyprlock's
        blur_passes = 1 once the image has been scaled up to the monitor.
        Set to 0 for no blur.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm.theme = "hyprlock";

    # sddm.conf points ThemeDir at /run/current-system/sw/share/sddm/themes.
    environment.systemPackages = [ theme ];
  };
}
