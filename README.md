# flake-catalog

Versioned Nix flake catalog for Hakula's projects. Packages are the upstream derivations, with each project's locked dependencies and toolchain preserved.

## Outputs

| Output                                     | x86_64-linux | aarch64-darwin |
| ------------------------------------------ | ------------ | -------------- |
| `packages.<system>.activity-report`        | Yes          | Yes            |
| `packages.<system>.agent-project-move`     | Yes          | Yes            |
| `packages.<system>.listenbrainz-scrobbler` |              | Yes            |
| `packages.<system>.oxide-code`             | Yes          | Yes            |
| `packages.<system>.wakatime-cli`           | Yes          | Yes            |

`homeModules.activity-report`, `homeModules.agent-project-move`, `homeModules.listenbrainz-scrobbler`, and `homeModules.oxide-code` expose the original upstream Home Manager modules. `lib.skills` exposes [Plugins](https://github.com/hakula139/plugins)' skill sources. `overlays.default` aliases the packages above into the consumer's package set.

The initial selection includes Activity Report v0.2.0, Agent Project Move v0.3.0, ListenBrainz Scrobbler v0.3.0, Oxide Code v0.1.0-alpha.11 (prerelease), and WakaTime CLI v2.28.4-hakula.1 (prerelease). Plugins distributes through its main branch and plugin manifest versions. `flake.lock` fixes every selected revision.

## Consume

Add the catalog to a flake and commit the resulting lock. Once a snapshot is published, select its immutable tag, such as `github:hakula139/flake-catalog/v0.1.0`.

```nix
inputs.flake-catalog.url = "github:hakula139/flake-catalog";
```

Select packages directly:

```nix
environment.systemPackages = [
  inputs.flake-catalog.packages.${pkgs.stdenv.hostPlatform.system}.wakatime-cli
];
```

For Home Manager, import the named module and explicitly select its catalog package. Activity Report and Agent Project Move otherwise construct their default package with the host's package set.

```nix
imports = [ inputs.flake-catalog.homeModules.activity-report ];
programs.activity-report = {
  enable = true;
  package = inputs.flake-catalog.packages.${pkgs.stdenv.hostPlatform.system}.activity-report;
};
```

Alternatively, add `inputs.flake-catalog.overlays.default` to `nixpkgs.overlays` and select `pkgs.activity-report`. Install individual skill sources through `home.file`:

```nix
home.file.".agents/skills/review".source = inputs.flake-catalog.lib.skills.review;
```

Keep project input graphs intact. Consumer overrides of the catalog's project inputs or their dependencies change the tested derivations. The catalog's own nixpkgs, Home Manager, and devkit inputs support development and integration checks.

## Cache and updates

When the catalog is the root flake, direct commands such as `nix develop` can prompt to trust its cache settings. Using the catalog as an input does not inherit its `nixConfig`. To use the cache in a consuming flake, add `https://hakula.cachix.org` to the root flake's `nixConfig.extra-substituters` and `hakula.cachix.org-1:7zwB3fhMfReHdOjh6DmnaLXgqbPDBcojvN9F+osZw0k=` to `nixConfig.extra-trusted-public-keys`, or add them to the host's `nix.settings.extra-substituters` and `nix.settings.extra-trusted-public-keys` under its existing trust policy.

Cache availability depends on upstream publication and retention. Default-branch catalog CI can upload with `CACHIX_AUTH_TOKEN` configured.

Project version changes update the explicit input URLs and `flake.lock` in reviewed changes. Plugins updates advance its locked main revision. Catalog snapshot versions are independent of project versions. Removing or renaming an output or dropping a platform requires a major snapshot version. Additions are minor, and compatible corrections and project updates are patch changes unless an integration contract changes.

Enter `nix develop`, run `run-hooks`, and run `nix flake check --all-systems`. CI builds the native checks on Linux and macOS. Checks cover exported packages, overlay identity, and Home Manager integration. Project repositories own package recipes, language tests, and toolchain updates.

Shared [CI](https://github.com/hakula139/devkit/blob/v3/docs/ci.md) and [release procedures](https://github.com/hakula139/devkit/blob/v3/docs/releasing.md) come from devkit. The tag workflow waits for passing CI on the tagged commit and publishes that version's `CHANGELOG.md` section as a snapshot release.
