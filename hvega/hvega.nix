{ mkDerivation, aeson, aeson-pretty, base, bytestring, containers
, filepath, stdenv, tasty, tasty-golden, text, unordered-containers
, zlib
}:
mkDerivation {
  pname = "hvega";
  version = "0.7.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [ aeson base text unordered-containers ];
  executableHaskellDepends = [ zlib ];
  testHaskellDepends = [
    aeson aeson-pretty base bytestring containers filepath tasty
    tasty-golden text
  ];
  homepage = "https://github.com/DougBurke/hvega";
  description = "Create Vega-Lite visualizations (version 4) in Haskell";
  license = stdenv.lib.licenses.bsd3;
}
