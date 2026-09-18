---
id: commands-maintenance
title: Maintenance Commands
---

## reg

```bash
fsda reg <module> -a <app> [--strict]
```

Registers a module into an app wrapper and injects managed integration points.

What happens:

- Generates app-side module wrapper files in `apps/<app>/lib/modules/<module>`.
- Injects managed snippets into app dependency, DI, route, l10n delegate, and failure mapping checkpoints.
- Prints affected paths summary.

## di

```bash
fsda di <module> -a <app> [--strict]
```

Synchronizes feature DI registrations into the app module DI wrapper.

What happens:

- Scans all feature layers inside target module.
- Appends only missing DI registrations and register-call invocations.
- Preserves existing custom code.

## rm-reg

```bash
fsda rm-reg <module> -a <app>
```

Removes module registration from target app and cleans managed snippets.

## rm-feature

```bash
fsda rm-feature <feature> -m <module> [--hook-disabled]
```

Removes a feature folder and rolls back managed shared/l10n injections.

What happens:

- Deletes feature directory.
- Removes feature export from module barrel.
- Removes feature-prefix exception/failure/failure-x snippets.
- Removes feature ARB keys (including paired metadata entries).
- Runs post-hooks unless `--hook-disabled` is used.

## cp-ui

```bash
fsda cp-ui <new_slice> -f <feature> -m <module> --from <from_slice>
```

Copies an existing UI slice flow into a new slice name for reuse with minor adjustments.

What happens:

- Copies only ui slice directory from `<from_slice>` to `<new_slice>`.
- Skips generated files (`*.freezed.dart`, `*.g.dart`) to avoid stale generated artifacts.
- Renames copied filenames and class symbols in copied UI files from source slice token to new slice token.
- Duplicates related ui export lines in feature barrel when available.

Notes:

- Logic/domain/data files are not copied; copied UI stays reusable against existing resources.
- Command aborts when target slice already exists to prevent overwrite.

## refresh

```bash
fsda refresh <module>
```

Runs lightweight module codegen refresh hooks.

What happens:

- Targets module root `modules/<module>`.
- Runs:
  - `flutter gen-l10n`
  - `dart run build_runner build --delete-conflicting-outputs --force-jit`

Use this for fast sync after non-structural edits.

## rebuild

```bash
fsda rebuild <module>
```

Runs full module rebuild pipeline.

What happens:

- Targets module root `modules/<module>`.
- Runs:
  - `flutter clean`
  - `flutter pub get`
  - `flutter gen-l10n`
  - `dart run build_runner build --delete-conflicting-outputs --force-jit`

Use this after heavy generator/refactor cycles or when module build state is stale.

## fix-import

```bash
fsda fix-import [-m <module>] [-a <app>]
```

Runs import fixes and normalizes feature barrel export ordering by layer markers.
