# Idle handling. The lock listener is only emitted when hyprlock is configured,
# so hosts without a lock screen (alr-game) just get DPMS.
{ config, lib, ... }:

let
  cfg = config.local.hypridle;
  lockEnabled = config.programs.hyprlock.enable;
in
{
  options.local.hypridle = {
    enable = lib.mkEnableOption "the shared hypridle configuration";

    lockTimeout = lib.mkOption {
      type = lib.types.int;
      default = 300;
      description = "Seconds of idle before locking. Ignored without hyprlock.";
    };

    dpmsTimeout = lib.mkOption {
      type = lib.types.int;
      default = 600;
      description = "Seconds of idle before turning the displays off.";
    };
  };

  config.services.hypridle = lib.mkIf cfg.enable {
    enable = true;

    settings = {
      listener =
        lib.optional lockEnabled {
          timeout = cfg.lockTimeout;
          on-timeout = "loginctl lock-session";
        }
        ++ [{
          timeout = cfg.dpmsTimeout;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }];
    }
    // lib.optionalAttrs lockEnabled {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
    };
  };
}
