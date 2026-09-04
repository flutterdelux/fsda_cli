---
id: commands-workspace
title: Workspace Commands
---

These commands manage workspace structure, package templates, and app package synchronization.

## create

```bash
fsda create <workspace_name>
```

Creates a new workspace folder with baseline directories and config.

What happens:

- Creates `<workspace_name>/apps`, `<workspace_name>/modules`, and `<workspace_name>/packages`.
- Creates `<workspace_name>/fsda.yaml` populated with package templates available in the CLI bundle.
- Prints affected paths summary.

Rerun behavior:

- If workspace folder already exists, command stops and does not modify files.

## configure

```bash
fsda configure
```

Synchronizes `workspace/packages` to match active package list in `fsda.yaml`.

What happens:

- Reads `fsda.yaml` key `packages`.
- Ignores unknown package names that are not available in bundled templates.
- Removes managed template package folders that are no longer listed.
- Generates missing managed template package folders that are listed.
- Prints `added/removed/kept` summary and affected paths.

Rerun behavior:

- Idempotent for already-synced state.
- Existing desired package folders are kept.
- Unlisted managed package folders are removed.

## configure-app

```bash
fsda configure-app <app>
```

Synchronizes app dependencies and DI external wiring based on active workspace packages.

What happens:

- Targets `apps/<app>/pubspec.yaml`.
- Ensures managed package path dependencies under `dependencies:` match active folders in `workspace/packages`.
- Removes managed package entries when package folder is no longer active.
- Reads `infra_*` template specs and installs missing app dependencies via `dart pub add`.
- Synchronizes infra DI snippets/imports in:
	- `apps/<app>/lib/core/di/core_di.dart`
	- `apps/<app>/lib/core/di/external_di.dart`
- Synchronizes external config files in `apps/<app>/lib/core/externals`.
- Prints synchronization counters and affected paths.

Rerun behavior:

- Idempotent when app is already aligned.
- Adds only missing managed dependencies/snippets and removes stale managed ones.

## list-pckg

```bash
fsda list-pckg
```

Lists package template names available inside the bundled package registry.

What happens:

- Reads bundled template catalog.
- Prints sorted package names.

Rerun behavior:

- Read-only command, no file changes.

## add-pckg

```bash
fsda add-pckg <name>
```

Adds one package template to workspace and ensures it is active in `fsda.yaml`.

What happens:

- Validates package name and existence in bundled template catalog.
- Updates `fsda.yaml` packages list:
	- keeps if already active
	- re-activates if previously commented
	- appends if missing
- Generates `packages/<name>` only when the folder does not already exist.
- Runs template dependency/dev-dependency/post-hook pipeline for new package generation.
- Prints affected paths summary.

Rerun behavior:

- If `packages/<name>` already exists, generation is skipped to prevent overwrite.
