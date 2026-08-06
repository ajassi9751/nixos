{ ... }: {
  perSystem =
    { pkgs, ... }:
    let
      upload-service-program = pkgs.rustPlatform.buildRustPackage rec {
        pname = "upload-service";
        version = "0.1.0";
        src = ./upload-service/.;
        cargoLock.lockFile = ./upload-service/Cargo.lock;
      };
    in
    {
      packages.upload-service = upload-service-program;
    };
}
