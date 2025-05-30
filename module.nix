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
        specialArgs = rec {
          inherit (self) bienenstockLib;
          inherit system;

          pkgs = import nixpkgs {
            inherit system;

            config = {
              allowUnfree = true;
              allowUnsupportedSystem = true;
              cudaSupport = true;
            };
          };

          bienenstockPkgs = mkIf cfg.enablePackages (bienenstockLib {
            inherit pkgs;
          });
        };

        modules = modules ++ [
          (
            { pkgs, modulesPath, ... }:
            {
              imports = [ (modulesPath + "/misc/nixpkgs/read-only.nix") ];
              nixpkgs = { inherit pkgs; };
            }
          )
          (
            { pkgs, ... }:
            {
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
