# AGENTS.md: flake-catalog

`flake-catalog` is a versioned Nix flake catalog that re-exports pinned upstream packages, Home Manager modules, and agent skills with each project's locked dependency graph intact.

## Rules for every change

- Wrap code and comments at 100 columns, counting the indent, end section banners at column 100, and keep a single-line string literal whole at any length.
- Keep each cataloged project input free of root `follows` overrides so its tested transitive dependencies and toolchain stay unchanged. Only `devkit` and `home-manager` follow the catalog's `nixpkgs`.
- Track each project's upstream default branch in `flake.nix` and pin its exact revision in `flake.lock`. Run `nix flake update <input>` to refresh one project. Update the `README.md` outputs table whenever outputs or supported systems change.

## Verification

In each new checkout or worktree, run `nix develop -c true` once to install the pre-commit hooks and link their config, and never bypass them with `--no-verify` or `PREK_ALLOW_NO_CONFIG`.

```bash
nix flake check --all-systems
nix develop -c run-hooks
```
