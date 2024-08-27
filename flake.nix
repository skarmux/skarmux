{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ { flake-parts, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } {

    systems = [ "x86_64-linux" "aarch64-linux" ];
    
    flake = {
      nixosModules.default = import ./nix/module/homepage.nix inputs;
    };
    
    perSystem = { pkgs, ... }:
    let
      homepage = pkgs.callPackage ./homepage.nix {};
    in {

      packages = {
        homepage = homepage;
        default = homepage;
      };

      devShells.default = pkgs.mkShell {

        packages = with pkgs; [
          # Generate class-based main.css
          tailwindcss
          # Run multiple predefined processes
          mprocs
          # Serve static files locally
          webfs
          # Formatter
          rustywind # Reorder tailwindcss classes
          nodePackages.prettier # Node.js :(
        ];
      };
    };
  };
}
