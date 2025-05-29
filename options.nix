{ inputs, ... }:
with inputs.nixpkgs.lib;
{
  options = {
    flake.bienenstockLib = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = ''
        Define custom library functions (and packages) to pass to all hosts.  
        May be instantiated by calling using an attrset containing a nixpkgs instance `pkgs`.

        When instantiated, all functions in the `packages` attr will be wrapped in `pkgs.callPackage`.
        This behaviour can be controlled using `bienenstock.enablePackages`.

        The packages will also be available as `bienenstockPkgs` as a module argument.
      '';
    };

    deploy = mkOption {
      default = { };
      type = types.attrsOf types.anything;
      description = "The underlying deploy-rs configuration. Defined so that the module system can merge definitions.";
    };

    bienenstock = mkOption {
      default = { };
      description = "Configuration for bienenstock";
      type = types.submodule {
        options = {
          hosts = mkOption {
            default = { };
            description = "The hosts which can be deployed.";
            type = types.attrsOf (
              types.submodule {
                options = {
                  system = mkOption {
                    type = types.str;
                    description = "The host's system and architecture";
                  };

                  targetUser = mkOption {
                    type = types.str;
                    description = "The user to log in as. Defaults to root.";
                    default = "root";
                  };

                  targetHost = mkOption {
                    type = types.nullOr types.str;
                    description = "The host's IP or FQDN. Defaults to the host's name.";
                    default = null;
                  };

                  targetPort = mkOption {
                    type = types.int;
                    description = "The port the SSH daemon is running on. Defaults to 22.";
                    default = 22;
                  };

                  targetBastion = mkOption {
                    type = types.nullOr types.str;
                    description = "The SSH jump host's name, if needed.";
                    default = null;
                  };

                  modules = mkOption {
                    type = types.listOf types.path;
                    description = "NixOS modules to load";
                    default = [ ];
                  };

                  remoteBuild = mkOption {
                    type = types.bool;
                    description = "Whether to run the build on the target machine.";
                    default = false;
                  };
                };
              }
            );
          };

          rootAuthorizedKeys = mkOption {
            type = types.listOf types.str;
            description = "A list of SSH keys to apply to all hosts";
            default = [ ];
          };

          enablePackages = mkOption {
            type = types.bool;
            description = "See documentation of bienenstockLib.";
            default = false;
          };

          sshConfig = mkOption {
            type = types.str;
            description = "The resulting SSH config";
            default = "";
          };

          modules = mkOption {
            type = types.listOf types.path;
            description = "NixOS modules to load on all hosts";
            default = [ ];
          };
        };
      };
    };
  };
}
