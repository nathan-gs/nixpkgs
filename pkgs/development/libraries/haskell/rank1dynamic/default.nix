# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, binary }:

cabal.mkDerivation (self: {
  pname = "rank1dynamic";
  version = "0.2.0.0";
  sha256 = "09p3lggnsn0355440d9cazwijv9qm4siw99gg2xkk2hamp2sj42h";
  buildDepends = [ binary ];
  meta = {
    homepage = "http://haskell-distributed.github.com";
    description = "Like Data.Dynamic/Data.Typeable but with support for rank-1 polymorphic types";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
