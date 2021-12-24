{
  network = {
    pkgs = import
      (builtins.fetchGit {
        name = "nixos-21.11-2021-12-19";
        url = "https://github.com/NixOS/nixpkgs";
        ref = "refs/heads/nixos-21.11";
        rev = "e6377ff35544226392b49fa2cf05590f9f0c4b43";
      })
      { };
  };

  nixie = { modulesPath, lib, name, ... }: {
    imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
      (modulesPath + "/virtualisation/digital-ocean-config.nix")
    ];

    deployment.targetHost = "198.51.100.207";
    deployment.targetUser = "root";

    networking.hostName = name;

    system.stateVersion = "21.11"; # Do not change lightly!

    deployment.healthChecks = {
      http = [
        {
          scheme = "http";
          port = 80;
          path = "/";
          description = "check that nginx is running";
        }
      ];
    };

    networking.firewall.allowedTCPPorts = [ 80 ];

    services.nginx = {
      enable = true;
      virtualHosts.default = {
        default = true;
        locations."/".return = "200 \"Hello from Nixie!\"";
      };
    };
  };
}
