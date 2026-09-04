---
id: commands-maintenance
title: Maintenance Commands
---

## reg

```bash
fsda reg <module> -a <app> [--strict]
```

Registers a module into an app by generating wrapper files and injecting integration points.

What happens:

- Generates module wrapper files in `apps/<app>/lib/modules/<module>`.
- Injects managed module dependency entry in `apps/<app>/pubspec.yaml`.
- Injects module integration snippets into app files based on template manifest:
	- DI wiring
	- route registration
	- l10n delegates
	- failure extension mapping
- Prints affected paths summary.

Rerun behavior:

- Existing wrapper files are skipped by default.
- Existing equivalent injection snippets are not duplicated.

Strict mode behavior:

- Fails if wrapper files already exist.
- Fails if required target file or injection anchor is missing.

## di

```bash
fsda di <feature> -m <module> -a <app> [--strict]
```

Synchronizes feature DI registration into module DI wrapper.

What happens:

- Scans feature classes under datasource/repository/usecase/logic layers.
- Targets app module DI file: `apps/<app>/lib/modules/<module>/<module>_di.dart`.
- Creates feature method if missing (for example `_walletDi`).
- Appends only missing registration lines.
- Injects missing call to feature DI method in register pipeline.
- Prints affected paths summary.

This flow is incremental and idempotent:

- existing custom code is preserved
- only missing registrations are appended

Strict mode behavior:

- Fails if DI method or register-call insertion cannot be applied safely.

## rm-reg

```bash
fsda rm-reg <module> -a <app>
```

Removes module registration and cleans injected references.

What happens:

- Removes module dependency mapping from `apps/<app>/pubspec.yaml`.
- Removes previously injected snippets from DI/route/l10n/failure files.
- Deletes wrapper directory `apps/<app>/lib/modules/<module>`.
- Prints affected paths summary.

Rerun behavior:

- Missing targets are reported as skipped when already clean.

## fix-import

```bash
fsda fix-import [-m <module>] [-a <app>]
```

Runs automatic import ordering and unused import cleanup.

What happens:

- Runs `dart fix --apply --code=directives_ordering --code=unused_import`.
- Supports app and module target scopes.
- Writes formatter/fix changes directly in selected target project(s).
