let
  resourcesByType = (import ./parsetf.nix { }).resourcesByType;

  droplets = resourcesByType "digitalocean_droplet";
  backends = builtins.filter (d: d.name == "backend") droplets;
  loadbalancers = builtins.filter (d: d.name == "loadbalancer") droplets;

  mkBackend = resource: { name, ... }: {
    imports = [ ./common.nix ];

    deployment.targetHost = resource.values.ipv4_address;
    networking.hostName = resource.values.name;

    networking.firewall.interfaces.ens4.allowedTCPPorts = [ 80 ];
    services.nginx = {
      enable = true;
      virtualHosts.default = {
        default = true;
        locations."/".return = "200 \"Hello from ${name} at ${resource.values.ipv4_address}\"";
      };
    };
  };

  mkLoadBalancer = resource: { name, ... }: {
    imports = [ ./common.nix ];

    deployment.targetHost = resource.values.ipv4_address;
    networking.hostName = resource.values.name;

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
        name = "nixos-21.11-2021-12-19";
        url = "https://github.com/NixOS/nixpkgs";
        ref = "refs/heads/nixos-21.11";
        rev = "e6377ff35544226392b49fa2cf05590f9f0c4b43";
      })
      { };
  };
} //
builtins.listToAttrs (map (r: { name = r.values.name; value = mkBackend r; }) backends) //
builtins.listToAttrs (map (r: { name = r.values.name; value = mkLoadBalancer r; }) loadbalancers)
