---
id: commands-generation
title: Generation Commands
---

This page covers core workspace generation commands.

For specialized generation surfaces, use:

- Slice commands: see `Slice Commands`
- Model and enum commands: see `Modelling Commands`
- Shared field commands: see `Input Commands`
- UI scaffold commands: see `UI Commands`

## gen-app

```bash
fsda gen-app <app>
```

Generates a Flutter app in `apps/<app>`.

What happens:

- Runs `flutter create` in app target folder.
- Applies FSDA app brick overlay.
- Installs app dependencies from template spec.
- Executes configured post-hooks.

Rerun behavior:

- Stops if `apps/<app>` already exists.

## gen-module

```bash
fsda gen-module <module> [--hook-disabled]
```

Generates module baseline in `modules/<module>`.

What happens:

- Bakes module brick into module target folder.
- Installs module dependencies from template spec.
- Runs module post-hooks.

Rerun behavior:

- Stops if `modules/<module>` already exists.

## gen-feature

```bash
fsda gen-feature <feature> -m <module> [--ds <datasource_mode>|--datasource <datasource_mode>] [--hook-disabled]
```

Generates feature baseline in `modules/<module>/lib/src/features/<feature>`.

What happens:

- Bakes feature brick into feature folder.
- Applies datasource mode (`both`, `remote`, `local`).
- Injects baseline exception/failure/l10n checkpoints.
- Updates module barrel export.

Rerun behavior:

- Stops if feature folder already exists.

## regen-feature

```bash
fsda regen-feature <feature> -m <module> [--ds <datasource_mode>|--datasource <datasource_mode>]
```

Regenerates only missing baseline files for an existing feature.

What happens:

- Rebuilds baseline into a temporary folder.
- Copies only missing files into feature target.
- Preserves existing files.
- Refreshes feature barrel data exports when required.

## Hook Skip Behavior

For commands supporting `--hook-disabled`:

- Post-hooks are skipped.
- Manual next-step commands are printed for later execution.
