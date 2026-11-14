# ==================================================================================================
# Catalog Integration Checks
# ==================================================================================================

{
  self,
  inputs,
  pkgs,
}:

let
  inherit (pkgs) lib;
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (pkgs.stdenv) isDarwin;

  packages = self.packages.${system};
  upstreamPackages = {
    inherit (inputs.activity-report.packages.${system}) activity-report;
    inherit (inputs.agent-project-move.packages.${system}) agent-project-move;
    inherit (inputs.oxide-code.packages.${system}) oxide-code;
    inherit (inputs.wakatime-cli.packages.${system}) wakatime-cli;
  }
  // lib.optionalAttrs isDarwin {
    inherit (inputs.listenbrainz-scrobbler.packages.${system}) listenbrainz-scrobbler;
  };

  packagePaths = lib.mapAttrs (
    _: package: {
      inherit (package) drvPath outPath;
    }
  );

  moduleNames = [
    "activity-report"
    "agent-project-move"
    "oxide-code"
  ]
  ++ lib.optional isDarwin "listenbrainz-scrobbler";

  settings = {
    activity-report.labels.default = [ "work" ];
    oxide-code.client.effort = "high";
  };

  # Reconstructing either Nushell package with the host's zstd must change its derivation.
  consumerPkgs = pkgs.extend (_: prev: { zstd = prev.hello; });

  evalHome =
    modules: skills:
    (inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs.pkgs = consumerPkgs;
      modules = modules ++ [
        {
          home = {
            username = "catalog-test";
            homeDirectory = if isDarwin then "/Users/catalog-test" else "/home/catalog-test";
            stateVersion = "26.05";
            file = lib.mapAttrs' (
              name: source: lib.nameValuePair ".agents/skills/${name}" { inherit source; }
            ) skills;
          };

          programs = {
            activity-report = {
              enable = true;
              package = upstreamPackages.activity-report;
              settings = settings.activity-report;
            };

            agent-project-move = {
              enable = true;
              package = upstreamPackages.agent-project-move;
            };

            oxide-code = {
              enable = true;
              package = upstreamPackages.oxide-code;
              settings = settings.oxide-code;
              context = "Use the project instructions.\n";
            };
          };

          services = lib.optionalAttrs isDarwin {
            listenbrainz-scrobbler = {
              enable = true;
              package = upstreamPackages.listenbrainz-scrobbler;
            };
          };
        }
      ];
    }).config;

  catalog = evalHome (map (name: self.homeModules.${name}) moduleNames) self.lib.skills;
  upstream = evalHome (map (
    name: inputs.${name}.homeModules.default
  ) moduleNames) inputs.plugins.lib.skills;

  snapshot = config: {
    packages = map (package: package.drvPath) config.home.packages;
    files = lib.mapAttrs (_: file: {
      source = toString file.source;
      inherit (file) text;
    }) config.home.file;
    launchd = lib.optionalAttrs isDarwin config.launchd.agents;
  };

  installed = map (package: package.drvPath) catalog.home.packages;
  skillSource = name: toString catalog.home.file.".agents/skills/${name}".source;
  overlay = self.overlays.default {
    stdenv.hostPlatform = { inherit system; };
    callPackage = _: _: throw "catalog overlay reconstructed a package";
  } { };
in
{
  overlay =
    assert lib.assertMsg (
      packagePaths packages == packagePaths upstreamPackages
    ) "catalog package identity differs from upstream";
    assert lib.assertMsg (
      packagePaths overlay == packagePaths upstreamPackages
    ) "catalog overlay package identity differs from upstream";
    pkgs.emptyFile;

  home-manager =
    assert lib.assertMsg (
      snapshot catalog == snapshot upstream
    ) "catalog Home Manager configuration differs from direct upstream imports";
    assert lib.assertMsg (lib.all (
      name: builtins.elem upstreamPackages.${name}.drvPath installed
    ) moduleNames) "Home Manager did not install the selected upstream packages";
    assert lib.assertMsg (
      skillSource "activity-report" == "${upstreamPackages.activity-report}/share/skills/activity-report"
      &&
        skillSource "agent-project-move"
        == "${upstreamPackages.agent-project-move}/share/skills/agent-project-move"
      && lib.all (name: skillSource name == toString inputs.plugins.lib.skills.${name}) (
        builtins.attrNames inputs.plugins.lib.skills
      )
    ) "Home Manager skill links differ from their upstream sources";
    pkgs.emptyFile;
}
