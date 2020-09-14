{
  pkgs,
  buildPackages,
  stdenv,
  rustBuilder,
}:
args@{
  rustChannel,
  rustSha256 ? null,
  packageFun,
  packageOverrides ? pkgs: pkgs.rustBuilder.overrides.all,
  ...
}:
let
  rustChannel = buildPackages.rustChannelOf {
    channel = args.rustChannel;
    sha256 = args.rustSha256;
  };
  inherit (rustChannel) cargo;
  rustc = rustChannel.rust.override {
    targets = [
      (rustBuilder.rustLib.realHostTriple stdenv.targetPlatform)
    ];
  };
  extraArgs = builtins.removeAttrs args [ "rustChannel" "rustSha256" "packageFun" "packageOverrides" ];
in
rustBuilder.makePackageSet (extraArgs // {
  inherit cargo rustc packageFun;
  packageOverrides = packageOverrides pkgs;
  buildRustPackages = buildPackages.rustBuilder.makePackageSet (extraArgs // {
    inherit cargo rustc packageFun;
    packageOverrides = packageOverrides buildPackages;
  });
})
