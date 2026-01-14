{ config, pkgs, ... }:

{
  networking.extraHosts =
    ''
	10.80.90.10 kali.nat
	10.99.99.10 kali.ho


    '';

}
