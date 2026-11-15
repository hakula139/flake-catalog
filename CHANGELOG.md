# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.2] - 2026-11-15

### Changed

- Make Dream proposals resumable across sessions and refresh issue-title and Nushell guidance.

### Fixed

- Fix infinite recursion when applying the catalog overlay to nixpkgs, allowing consumer development shells to evaluate.
- Update Activity Report to v0.2.1 to retain native Codex agent time and exclude imported spans while preserving native continuations.

[0.1.2]: https://github.com/hakula139/flake-catalog/compare/v0.1.1...v0.1.2

## [0.1.1] - 2026-11-15

### Fixed

- Update the Git workflow skill exposed through `lib.skills` to poll GitHub checks and workflow runs every 60 seconds while waiting for completion.

[0.1.1]: https://github.com/hakula139/flake-catalog/compare/v0.1.0...v0.1.1

## [0.1.0] - 2026-11-15

### Added

- Install Activity Report, Agent Project Move, Oxide Code, and WakaTime CLI through named packages on x86_64 Linux and Apple Silicon macOS. ListenBrainz Scrobbler is available on Apple Silicon macOS.
- Import the original Home Manager modules through `homeModules.activity-report`, `homeModules.agent-project-move`, `homeModules.listenbrainz-scrobbler`, and `homeModules.oxide-code`.
- Access Plugins' skill sources through `lib.skills` and fixed package aliases through `overlays.default`. Direct packages and overlay aliases preserve each upstream project's locked dependency graph and toolchain.

[0.1.0]: https://github.com/hakula139/flake-catalog/releases/tag/v0.1.0
