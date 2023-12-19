{
  description = "Custom-Built MLIR";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-23.05";

  outputs = { self, nixpkgs }:
    let

      # git revision to use (for version and git pull)
      gitRevision = "47db1e2ab9541dd94a75d5812cdbad6c3c3d7a42";
      gitSha256 = "sha256-z6VII5GUb+ifStBfLQULyXp7IsAa8Wiw6KV0qH0BTNA=";

      version = gitRevision;

      # System types to support.
      supportedSystems = [ "x86_64-linux" ]; #"x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in
    {
      # A Nixpkgs overlay.
      overlay = final: prev: {
        mlir = with final; llvmPackages_16.stdenv.mkDerivation {
          name = "llvm-mlir";

          src = fetchFromGitHub {
            owner = "llvm";
            repo = "llvm-project";
            rev = gitRevision;
            sha256 = gitSha256;
          };

          sourceRoot = "source/llvm";

          nativeBuildInputs = [
            cmake
            llvmPackages_16.bintools
            llvmPackages_16.clang
            llvmPackages_16.llvm
            ncurses
            ninja
            perl
            python3
            zlib
          ];

          buildInputs = [ libxml2 ];

          cmakeFlags = [
            "-GNinja"
            # Debug for debug builds
            "-DCMAKE_BUILD_TYPE=Release"
            # from the original LLVM expr
            "-DLLVM_LINK_LLVM_DYLIB=ON"
            # install tools like FileCheck
            "-DLLVM_INSTALL_UTILS=ON"
            # change this to enable the projects you need
            "-DLLVM_ENABLE_PROJECTS=mlir"
            # this makes llvm only to produce code for the current platform, this saves CPU time, change it to what you need
            "-DLLVM_TARGETS_TO_BUILD=X86"
            "-DLLVM_ENABLE_ASSERTIONS=ON"
            # Using clang and lld speeds up the build, we recomment adding:
            "-DCMAKE_C_COMPILER=clang"
            "-DCMAKE_CXX_COMPILER=clang++"
            "-DLLVM_ENABLE_LLD=ON"
            "-DLLVM_PARALLEL_LINK_JOBS=2"
          ];
        };
      };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system: { inherit (nixpkgsFor.${system}) mlir; });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.mlir);
    };
}

