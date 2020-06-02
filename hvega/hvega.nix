{ mkDerivation, aeson, aeson-pretty, base, bytestring, containers
, filepath, stdenv, tasty, tasty-golden, text, unordered-containers
}:
mkDerivation {
  pname = "hvega";
  version = "0.9.0.1";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [ aeson base text unordered-containers ];
  testHaskellDepends = [
    aeson aeson-pretty base bytestring containers filepath tasty
    tasty-golden text unordered-containers
  ];
  homepage = "https://github.com/DougBurke/hvega";
  description = "Create Vega-Lite visualizations (version 4) in Haskell";
  license = stdenv.lib.licenses.bsd3;
}
