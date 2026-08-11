# Shared ssh client config.
{ config, ... }:

{
  programs.ssh = {
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
      };

      # Specific configuration for a remote server
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = [ "~/.ssh/alr.priv" ]; # Specific key for GitHub
        IdentitiesOnly = true; # Only use the key specified above
      };

    };
  };
}
