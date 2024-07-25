{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ { flake-parts, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } {

    systems = [ "x86_64-linux" "aarch64-linux" ];
    
    flake = {
      nixosModules.default = import ./modules/homepage/default.nix inputs;
    };
    
    perSystem = { pkgs, ... }:
    let
      homepage = pkgs.callPackage ./feaston-static.nix {};
    in {

      packages = {
        homepage = homepage;
        default = homepage;
      };

      devShells.default = pkgs.mkShell {

        DATABASE_URL="sqlite:./db.sqlite?mode=rwc";

        packages = with pkgs; [
          tailwindcss
          mprocs
          webfs
          grc # colorize output logs

          # Formatter
          nodePackages.prettier # Node.js :(
        ];
      };
    };
  };
}
