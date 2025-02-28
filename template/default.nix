{
  sources ? import ./sources,
  ...
}:
let
  inherit (sources.bienenstock) mkEntrypoint;
in
mkEntrypoint sources {
  imports = [
    sources.bienenstock.module
    ./lib
  ];

  bienenstock = {
    enablePackages = true;
    rootAuthorizedKeys = [ "ssh-rsa ..... user@host" ];

    hosts.myserver = {
      system = "x86_64-linux";
      modules = [ ./hosts/myserver/configuration.nix ];
      buildOnTarget = false;
      targetHost = "10.0.0.5";
    };
  };
}
