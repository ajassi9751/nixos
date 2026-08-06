{ pkgs, ... }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "upload-service";
  version = "0.1.0";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;
}
