# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, Cabal, lens, unorderedContainers }:

cabal.mkDerivation (self: {
  pname = "cabal-lenses";
  version = "0.3.1";
  sha256 = "17piwqyzd33shp12qa6j4s579rrs34l44x19p2nzz69anhc4g1j7";
  buildDepends = [ Cabal lens unorderedContainers ];
  meta = {
    description = "Lenses and traversals for the Cabal library";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
