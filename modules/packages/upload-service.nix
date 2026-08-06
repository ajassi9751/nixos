{ ... }: {
  perSystem =
    { pkgs, ... }:
    let
      upload-service-program = pkgs.callPackage ./upload-service
    in
    {
      packages.upload-service = upload-service-program;
    };
}
