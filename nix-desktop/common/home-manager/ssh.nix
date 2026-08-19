# Shared ssh client config.
#
# The two knobs exist because alr-work authenticates differently: it pins an
# identity for every host, and reaches GitHub with two FIDO2 tokens plus a
# separate key, where the other machines use one ordinary key.
{ config, lib, ... }:

let
  cfg = config.local.ssh;
in
{
  options.local.ssh = {
    defaultIdentityFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "~/.ssh/alr.priv";
      description = ''
        Identity to offer for every host, pinned with IdentitiesOnly so that
        the agent cannot walk through other keys first. Null leaves both
        directives out of the `*` block entirely, which is the default -- only
        set it on hosts that really do use one key everywhere.
      '';
    };

    githubIdentityFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "~/.ssh/alr.priv" ];
      example = [ "~/.ssh/id_ed25519_sk" "~/.ssh/alr.laud" ];
      description = ''
        Keys offered to github.com, in order. FIDO2 `sk` keys belong first:
        ssh tries them in sequence and each one that is not a token resolves
        without a touch.
      '';
    };
  };

  config.programs.ssh = {
    enable = true;

    # The "*" block below replaces home-manager's built-in defaults.
    enableDefaultConfig = false;

    # `settings` supersedes the deprecated `matchBlocks`. Attribute names become
    # `Host <name>` patterns, and the keys are ssh_config(5) directive names
    # verbatim rather than home-manager's camelCase aliases.
    settings = {

      # Common options for all connections
      "*" = {
        User = config.home.username; # Default user for all hosts
        ServerAliveInterval = 60;
      } // lib.optionalAttrs (cfg.defaultIdentityFile != null) {
        IdentityFile = cfg.defaultIdentityFile;
        IdentitiesOnly = true;
      };

      # Specific configuration for a remote server
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = cfg.githubIdentityFiles;
        IdentitiesOnly = true; # Only use the keys specified above
      };

    };
  };
}
