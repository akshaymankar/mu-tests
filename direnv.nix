let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
  pkgsFork = import sources.nixpkgs-ghc8105 {};
  hls = pkgs.haskell-language-server.override { supportedGhcVersions = ["8104"]; };
in
pkgs.buildEnv {
  name = "wire-cli";
  paths = [
    pkgs.pkgconfig
    pkgs.zlib
    # pkgsFork.haskell.compiler.ghc8105
    pkgs.haskell.compiler.ghc8104
    pkgs.haskellPackages.cabal-install
    pkgs.ncurses
    hls
    pkgs.ormolu
    pkgs.time
  ];
}
