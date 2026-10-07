# The graphical stack: Hyprland, its display manager, audio, and the bits they
# both need. Imported alongside base.nix by every host, since all three are
# desktops -- kept separate so a headless host could take base.nix alone.
{ pkgs, ... }:

{
  # nixpkgs' Hyprland, deliberately, rather than the upstream flake. The flake
  # pins its own nixpkgs, so its Mesa drifts from the system's: once the two
  # mesa-libgbm builds stopped matching, gbm_create_device() failed, aquamarine
  # came up with no allocator and Hyprland aborted in initServer -- which looks
  # exactly like a rejected login, since SDDM just redraws the greeter. nixpkgs
  # tracks 0.56.x (what the Lua configs in common/home-manager/ target) and is
  # built against the same Mesa as hardware.graphics, so the two cannot diverge.
  programs.hyprland.enable = true;

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
