{ inputs, ... }: {
  flakes.nixosModules.frc-package = { pkgs, system-arch, ... }: {
    environment.systemPackages = with inputs.frc-nix.packages.${system-arch}; [
      # I don't really use these
      vscode-wpilib
      advantagescope
      choreo
      pathplanner
      elastic-dashboard
      sysid
    ];
  };
}
