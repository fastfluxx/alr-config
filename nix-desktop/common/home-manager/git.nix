# Git identity, previously set by hand on each machine.
#
# The email differs per host: work commits from alr-work, personal from the
# other two. The name does not.
{ config, lib, ... }:

let
  cfg = config.local.git;
in
{
  options.local.git = {
    userName = lib.mkOption {
      type = lib.types.str;
      default = "Aleksander Rasmussen";
      description = "Name recorded as the commit author.";
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = "aleksrasmussen@gmail.com";
      description = ''
        Email recorded as the commit author. Defaults to the personal address;
        alr-work overrides it with the work one.
      '';
    };
  };

  # `settings` is the current option: it takes git config verbatim, section by
  # section. The older userName/userEmail/extraConfig spellings still work but
  # warn on every evaluation, and renames become removals.
  config.programs.git = {
    enable = true;

    settings = {
      user.name = cfg.userName;
      user.email = cfg.email;

      # Left pointing at the hand-maintained file rather than managed through
      # programs.git.ignores, which would take ownership of it. It currently
      # holds an absolute path to one checkout on this machine, so it is not
      # the same on every host and is not worth making declarative.
      core.excludesFile = "${config.home.homeDirectory}/.gitignore_global";
    };
  };
}
