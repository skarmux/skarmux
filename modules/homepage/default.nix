inputs: { config, lib, pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  cfg = config.services.homepage;
  defaultUser = "homepage";
  defaultGroup = "homepage";
in
{
  options = {
    services.homepage = {
      enable = lib.mkEnableOption ''
      Feaston event contribution planner     
      '';
      package = lib.mkOption {
        type = lib.types.package;
        default = inputs.self.packages.${system}.homepage;
        description = ''
        The package to use with the service.
        '';
      };
      domain = lib.mkOption {
        type = lib.types.str;
        description = ''
        Domain from which the service will be exposed.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {

    users = {
      groups.${defaultUser} = {};
      users.${defaultUser} = {
        group = defaultGroup;
        isSystemUser = true;
      };
    };

    services.nginx.virtualHosts = lib.mkIf cfg.enableNginx {
      "${cfg.domain}" = {
        enableACME = cfg.enableTLS;
        forceSSL = cfg.enableTLS;
        root = "${inputs.self.packages.${system}.homepage}/www";
        locations."/" = {
          tryFiles = "$uri $uri/ /index.html";
        };
      };
    };
  };
}
