inputs':

{
  self,
  config,
  inputs,
  ...
}:
let
  inherit (inputs) nixpkgs;
  inherit (inputs') deploy-rs;

  inherit (nixpkgs) lib;

  cfg = config.bienenstock;
in
with lib;
{
  config = {
    bienenstock.sshConfig = ''
      Include ~/.ssh/config

    ''
    + (
      attrsToList cfg.hosts
      |> builtins.map (
        { name, value }:
        value
        // {
          inherit name;
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
          ...
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
      ) ""
    );

    flake = {
      deploy.nodes = builtins.mapAttrs (
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
          sshOpts = [
            "-p"
            (builtins.toString targetPort)
          ]
          ++ optionals (targetBastion != null) [
            "-J"
            targetBastion
          ];

          hostname = targetHost;

          profiles.system = {
            user = "root";
            path = deploy-rs.lib."${system}".activate.nixos self.nixosConfigurations."${name}";
          };
        }
      ) cfg.hosts;

      nixosConfigurations = builtins.mapAttrs (
        name:
        { modules, system, ... }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit (self) bienenstockLib;
            inherit system;
          };

          modules = [
            nixpkgs.nixosModules.readOnlyPkgs
            (import ./configuration.nix {
              inherit
                cfg
                name
                nixpkgs
                ;
            })
          ]
          ++ cfg.modules
          ++ modules;
        }
      ) cfg.hosts;
    };
  };
}
