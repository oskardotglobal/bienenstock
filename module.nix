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
            (builtins.toString targetPort)
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
        specialArgs = rec {
          inherit (self) bienenstockLib;
          inherit system;

          pkgs = import nixpkgs {
            inherit system;

            config = {
              allowUnfree = true;
              allowUnsupportedSystem = true;
            };
          };

          bienenstockPkgs = mkIf cfg.enablePackages (bienenstockLib.packages pkgs);
        };

        modules =
          [
            nixpkgs.nixosModules.readOnlyPkgs
            (import ./configuration.nix { inherit cfg name nixpkgs; })
          ]
          ++ cfg.modules
          ++ modules;
      }
    ) cfg.hosts;
  };

}
