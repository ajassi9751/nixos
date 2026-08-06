{ ... }: {
  perSystem =
    { pkgs, ... }:
    let
      upload-service-program = ./upload-service/default.nix { inherit pkgs; };
    in
    {
      packages.upload-service = upload-service-program;
    };
}
