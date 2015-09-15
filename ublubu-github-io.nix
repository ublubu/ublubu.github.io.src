{ mkDerivation, base, hakyll, stdenv }:
mkDerivation {
  pname = "ublubu-github-io";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base hakyll ];
  license = stdenv.lib.licenses.unfree;
}
