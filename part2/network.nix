let
  resourcesByType = (import ./parsetf.nix { }).resourcesByType;

  droplets = resourcesByType "digitalocean_droplet";
  backends = builtins.filter (d: d.name == "backend") droplets;
  loadbalancers = builtins.filter (d: d.name == "loadbalancer") droplets;

  mkBackend = resource: { modulesPath, lib, name, ... }: {
    imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
      (modulesPath + "/virtualisation/digital-ocean-config.nix")
    ];
    deployment.targetHost = resource.values.ipv4_address;
    deployment.targetUser = "root";
    networking.hostName = resource.values.name;
    system.stateVersion = "20.09";

    networking.firewall.interfaces.ens4.allowedTCPPorts = [ 80 ];
    services.nginx = {
      enable = true;
      virtualHosts.default = {
        default = true;
        locations."/".return = "200 \"Hello from ${name} at ${resource.values.ipv4_address}\"";
      };
    };
  };

  mkLoadBalancer = resource: { modulesPath, lib, name, ... }: {
    imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
      (modulesPath + "/virtualisation/digital-ocean-config.nix")
    ];
    deployment.targetHost = resource.values.ipv4_address;
    deployment.targetUser = "root";
    networking.hostName = resource.values.name;
    system.stateVersion = "20.09";

    networking.firewall.allowedTCPPorts = [ 80 ];
    services.nginx = {
      enable = true;
      upstreams.backend.servers = builtins.listToAttrs
        (map (r: { name = r.values.ipv4_address_private; value = { }; })
          backends);
      virtualHosts.default = {
        default = true;
        locations."/".proxyPass = "http://backend";
      };
    };
  };
in
{
  network = {
    pkgs = import
      (builtins.fetchGit {
        name = "nixos-20.09-small-2020-12-26";
        url = "https://github.com/nixos/nixpkgs";
        ref = "refs/heads/nixos-20.09-small";
        rev = "ae1b121d9a68518dbf46124397e34e465d3cdf6c";
      })
      { };
  };
} //
builtins.listToAttrs (map (r: { name = r.values.name; value = mkBackend r; }) backends) //
builtins.listToAttrs (map (r: { name = r.values.name; value = mkLoadBalancer r; }) loadbalancers)
