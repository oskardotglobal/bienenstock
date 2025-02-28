flake:

{
  config,
  sources,
  ...
}:
let
  inherit (flake.inputs) sops-nix;
  inherit (sources) nixpkgs;
  inherit (nixpkgs) lib;

  cfg = config.bienenstock;
in
with lib;
{
  imports = [
    (import ./lib.nix flake)
  ];

  options = {
    colmena = mkOption {
      default = { };
      type = types.attrsOf types.anything;
      description = "The underlying colmena configuration. Defined so that the module system can merge definitions.";
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
                    type = types.str;
                    description = "The host's IP or FQDN. Defaults to the host's name.";
                    default = "";
                  };

                  targetPort = mkOption {
                    type = types.int;
                    description = "The port the SSH daemon is running on. Defaults to 22.";
                    default = 22;
                  };

                  modules = mkOption {
                    type = types.listOf types.path;
                    description = "NixOS modules to load";
                    default = [ ];
                  };

                  buildOnTarget = mkOption {
                    type = types.bool;
                    description = "Whether to build the system profiles on the target node itself.";
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
        };
      };
    };
  };

  config = {
    bienenstock.sshConfig =
      lib.attrsToList cfg.hosts
      |> builtins.map (
        { name, value }:
        {
          inherit name;
          inherit (value) targetHost targetPort targetUser;
        }
      )
      |> builtins.foldl' (
        acc:
        {
          name,
          targetHost ? name,
          targetUser ? "root",
          targetPort ? "22",
        }:
        let
          hostName = if targetHost != "" && targetHost != name then "HostName ${targetHost}" else "";
        in
        ''
          ${acc}

          Host ${name}
            User ${targetUser}
            Port ${builtins.toString targetPort}
            ${hostName}
        ''
      ) "";

    colmena =
      {
        meta = {
          inherit nixpkgs;
          allowApplyAll = lib.mkDefault false;
        };

        defaults = _: {
          nix = {
            settings.experimental-features = [
              "nix-command"
              "flakes"
              "pipe-operators"
            ];

            registry.nixpkgs.flake = nixpkgs;
            channel.enable = false;
            nixPath = [ "nixpkgs=${nixpkgs}" ];
          };

          users.users.root.openssh.authorizedKeys.keys = cfg.rootAuthorizedKeys;
          services.openssh = {
            enable = true;
            settings = {
              PasswordAuthentication = false;
              PubkeyAuthentication = true;
            };
          };

          imports = [ sops-nix.nixosModules.sops ];
        };
      }
      // builtins.mapAttrs (
        name: host: _:
        let
          pkgs = import nixpkgs { inherit (host) system; };
          libInstance = config.bienenstockLib { inherit pkgs; };
        in
        {
          _module.args = {
            inherit pkgs;
            bienenstockLib = libInstance;
            bienenstockPkgs = pkgs.lib.mkIf cfg.enablePackages libInstance.packages;
          };

          networking.hostName = name;

          deployment = {
            inherit (host)
              buildOnTarget
              targetHost
              targetPort
              targetUser
              ;

            replaceUnknownProfiles = false;
          };

          nixpkgs = {
            hostPlatform = host.system;
            config.allowUnfree = true;
          };

          imports = host.modules;
        }
      ) cfg.hosts;
  };

}
