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
      My personal Homepage. Try not to steal my swag.     
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

    services.nginx.virtualHosts = {
      "${cfg.domain}" = {
        # enableACME = true;
        # forceSSL = true;
        root = "${inputs.self.packages.${system}.homepage}/www";
        locations."/" = {
          tryFiles = "$uri $uri/ /index.html";
        };
      };
    };
  };
}
