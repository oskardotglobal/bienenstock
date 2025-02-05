localSelf:

{
  config,
  inputs,
  ...
}:
let
  inherit (localSelf.inputs) sops-nix;
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;

  cfg = config.flake.bienenstock;

  apply =
    let
      update = attrs: newAttrs: attrs // newAttrs;
      perSystem = f: builtins.mapAttrs (_: { system, ... }: f system);
    in
    hosts:
    hosts
    |> builtins.mapAttrs (
      _: host: {
        imports = host.modules ++ [ sops-nix.nixosModules.sops ];
        deployment = {
          inherit (host) buildOnTarget;
        };
      }
    )
    |> update {
      meta = {
        nixpkgs = nixpkgs.legacyPackages."${builtins.currentSystem}";

        nodeNixpkgs = perSystem (system: nixpkgs.legacyPackages."${system}") hosts;
        nodeSpecialArgs = perSystem (system: rec {
          inherit (cfg) rootAuthorizedKeys;
          pkgs = nixpkgs.legacyPackages."${system}";

          bienenstockLib = config.flake.bienenstockLib { inherit pkgs; };
          bienenstockPkgs = nixpkgs.lib.mkIf cfg.enablePackages bienenstockLib.packages;
        }) hosts;

        allowApplyAll = lib.mkDefault false;
      };

      defaults = import ./configuration.nix;
    };
in
with lib;
{
  imports = [
    (import ./lib.nix localSelf)
  ];

  options.flake = {
    colmena = mkOption {
      default = cfg.hosts;
      type = types.attrsOf types.anything;
      description = "The underlying colmena configuration. Defined so that flake-parts can merge definitions.";
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
            inherit apply;
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
        };
      };
    };
  };
}
