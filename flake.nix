{
  description = "Custom-Built MLIR";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  inputs.llvm-project = {
    url = "github:llvm/llvm-project";
    flake = false;
  };

  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, llvm-project, utils, ... }:
    let
      outputs = utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          mlir = import ./mlir.nix { pkgs = pkgs; llvmProject = llvm-project; };
        in {
          packages = {
            mlir = mlir;
            default = mlir;
          };

          devShells = {
            default = pkgs.mkShell {
              buildInputs = [ mlir ];
            };
          };
        }
      );
    in outputs // {
      overlays.default = final: prev: {
        mlir = outputs.packages.${prev.system}.mlir;
      };
    };
}