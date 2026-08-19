# Settings every host shares, whatever the machine is for.
#
# The rule for what belongs here: it is true of all three hosts *and* would
# stay true of a fourth. Anything that happens to match today but is really a
# property of one machine -- bootloader, GPU, disks -- stays in the host file.
{ pkgs, ... }:

{
  # Norwegian keyboard and console, but an English locale so that program
  # output and error messages stay greppable.
  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "no";
  services.xserver.xkb = {
    layout = "no";
    variant = "";
  };

  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" ];

  hardware.enableRedistributableFirmware = true;

  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  # Only the groups every host needs. Hosts that turn on libvirtd or docker
  # append their own -- extraGroups is a list, so the definitions merge rather
  # than one replacing the other.
  users.users.alr = {
    isNormalUser = true;
    description = "alr";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" ];
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    networkmanagerapplet # Wi-Fi tray icon
    brightnessctl # Screen brightness
  ];
}
