# The graphical stack: Hyprland, its display manager, audio, and the bits they
# both need. Imported alongside base.nix by every host, since all three are
# desktops -- kept separate so a headless host could take base.nix alone.
{ pkgs, inputs, ... }:

{
  programs.hyprland = {
    enable = true;
    # The flake input rather than nixpkgs: 0.56 is what the Lua configs in
    # common/home-manager/ target, and nixpkgs lags it.
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # Hosts add their own extraPackages (Intel VA-API) or enable32Bit (Steam).
  hardware.graphics.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  security.polkit.enable = true;
  security.rtkit.enable = true; # pipewire needs it for realtime scheduling

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  # Electron apps (Discord, VS Code) run natively on Wayland rather than XWayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
