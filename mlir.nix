{ pkgs, llvmProject }:

pkgs.stdenv.mkDerivation {
  name = "llvm-mlir";

  src = llvmProject;

  sourceRoot = "source/llvm";

  nativeBuildInputs = with pkgs; [
    bintools
    cmake
    llvmPackages.bintools
    llvmPackages.clang
    llvmPackages.llvm
    ncurses
    ninja
    perl
    pkg-config
    python3
    zlib
  ];

  buildInputs = with pkgs; [ libxml2 ];

  cmakeFlags = [
    "-GNinja"
    # Debug for debug builds
    "-DCMAKE_BUILD_TYPE=Release"
    # install tools like FileCheck
    "-DLLVM_INSTALL_UTILS=ON"
    # change this to enable the projects you need
    "-DLLVM_ENABLE_PROJECTS=mlir;clang;openmp"
    # this makes llvm only to produce code for the current platform, this saves CPU time, change it to what you need
    "-DLLVM_TARGETS_TO_BUILD=X86"
    "-DLLVM_ENABLE_ASSERTIONS=ON"
    # Using clang and lld speeds up the build, we recomment adding:
    "-DCMAKE_C_COMPILER=clang"
    "-DCMAKE_CXX_COMPILER=clang++"
    "-DLLVM_ENABLE_LLD=ON"
    "-DLLVM_PARALLEL_LINK_JOBS=4"
  ];
}