# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-11-15

### Added

- Install Activity Report, Agent Project Move, Oxide Code, and WakaTime CLI through named packages on x86_64 Linux and Apple Silicon macOS. ListenBrainz Scrobbler is available on Apple Silicon macOS.
- Import the original Home Manager modules through `homeModules.activity-report`, `homeModules.agent-project-move`, `homeModules.listenbrainz-scrobbler`, and `homeModules.oxide-code`.
- Access Plugins' skill sources through `lib.skills` and fixed package aliases through `overlays.default`. Direct packages and overlay aliases preserve each upstream project's locked dependency graph and toolchain.
- Package identity and Home Manager integration checks.

[0.1.0]: https://github.com/hakula139/flake-catalog/releases/tag/v0.1.0
