{
  nixie = { modulesPath, lib, name, ... }: {
    imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
      (modulesPath + "/virtualisation/digital-ocean-config.nix")
    ];

    deployment.targetHost = "198.51.100.207";
    deployment.targetUser = "root";

    networking.hostName = name;

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
