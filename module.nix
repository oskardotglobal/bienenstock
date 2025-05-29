{
  self,
  config,
  inputs,
  ...
}:
let
  inherit (inputs) nixpkgs deploy-rs;
  inherit (nixpkgs) lib;

  cfg = config.bienenstock;
in
with lib;
{
  options = {
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

  config = {
    bienenstock.sshConfig =
      attrsToList cfg.hosts
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
          targetBastion ? null,
        }:
        let
          hostName = optionalString (targetHost != name) "HostName ${targetHost}";
          proxyJump = optionalString (targetBastion != null) "ProxyJump ${targetBastion}";
        in
        trim ''
          ${acc}

          Host ${name}
            User ${targetUser}
            Port ${builtins.toString targetPort}
            ${hostName}
            ${proxyJump}
        ''
      ) "";

    flake.deploy.nodes = builtins.mapAttrs (
      name:
      {
        system,
        remoteBuild,
        targetUser,
        targetPort,
        targetHost,
        targetBastion ? null,
        ...
      }:
      {
        inherit remoteBuild;

        sshUser = targetUser;
        sshOpts =
          [
            "-p"
            targetPort
          ]
          ++ optionals (targetBastion != null) [
            "-j"
            targetBastion
          ];

        hostname = targetHost;

        profiles.system = {
          user = "root";
          path = deploy-rs.lib."${system}".activate.nixos self.nixosConfigurations."${name}";
        };
      }
    ) cfg.hosts;

    flake.nixosConfigurations = builtins.mapAttrs (
      name:
      { modules, system, ... }:

      nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = rec {
          inherit (self) bienenstockLib;
          inherit system;

          pkgs = nixpkgs.legacyPackages."${system}";

          bienenstockPkgs = mkIf cfg.enablePackages (bienenstockLib {
            inherit pkgs;
          });
        };

        modules = modules ++ [
          (
            { pkgs, ... }:
            {
              nixpkgs.config.allowUnfree = true;

              nix = {
                settings.experimental-features = [
                  "nix-command"
                  "flakes"
                  "pipe-operators"
                ];

                registry.nixpkgs.flake = nixpkgs;
                channel.enable = false;
                nixPath = [
                  "nixpkgs=${nixpkgs}"
                ];
              };

              users.users.root.openssh.authorizedKeys.keys = cfg.rootAuthorizedKeys;
              services.openssh = {
                enable = true;
                settings = {
                  PasswordAuthentication = false;
                  PubkeyAuthentication = true;
                };
              };

              programs.nh = {
                enable = true;
                clean.enable = pkgs.lib.mkDefault true;
              };

              networking.hostName = name;
            }
          )
        ];
      }
    ) cfg.hosts;
  };

}
