---
id: commands-maintenance
title: Maintenance
---

These commands manage code generation, localizations, and dependency configurations across modules (`modules/`) and applications (`apps/`) within your FSDA workspace.

## Workspace Guard

Must be executed inside an FSDA workspace root directory where `.fsda/config.yaml` is present. If executed outside, the command will abort immediately with an error.

## Options

All maintenance commands accept a module target, an application target, or **both combined**:

- `-m`, `--module <name>`: Targets a specific module inside the `modules/` directory.
- `-a`, `--app <name>`: Targets a specific application inside the `apps/` directory.

> **Note**: You must specify at least one target (`--module` or `--app`). Supplying both options will execute the command sequentially for both targets.

## Rerun Behavior

- **Repeatable & Safe**: Maintenance commands are completely safe to rerun at any time to re-trigger code generation, localization, or dependency refreshing.
- **Target Validation**: If a targeted module or app directory does not exist on disk, the command halts execution immediately with an error and takes no action.
- **Fail-Fast**: When targeting multiple items, if an error occurs during execution on any target, the command immediately halts and aborts the remaining pipeline.


## drb

```bash
# Target a module
fsda drb --module <module>

# Target an app
fsda drb -a <app>

# Target both simultaneously
fsda drb -m <module> -a <app>
```

Executes code generation (`build_runner`) inside the targeted module(s) or app(s).

### What Happens
1. **Validates Options**: Ensures at least one target (`--module` or `--app`) is provided.
2. **Directory Check**: Verifies that the target directories physically exist.
3. **Executes Build Runner**: Runs the code generation command in sequence for each provided target:

   ```bash
   dart run build_runner build --delete-conflicting-outputs --force-jit
   ```


## l10n

```bash
# Target a module
fsda l10n --module <module>

# Target an app
fsda l10n -a <app>

# Target both simultaneously
fsda l10n -m <module> -a <app>
```

Executes localization code generation (`flutter gen-l10n`) inside the targeted module(s) or app(s).

### What Happens
1. **Validates Options**: Ensures at least one target (`--module` or `--app`) is provided.
2. **Directory Check**: Verifies that the target directories physically exist.
3. **Executes Localization**: Runs the localization command in sequence for each provided target:

   ```bash
   flutter gen-l10n
   ```


## rebuild

```bash
# Target a module
fsda rebuild --module <module>

# Target an app
fsda rebuild -a <app>

# Target both simultaneously
fsda rebuild -m <module> -a <app>
```

Executes both `build_runner` and `flutter gen-l10n` sequentially inside the targeted module(s) or app(s).

### What Happens
1. **Validates Options**: Ensures at least one target (`--module` or `--app`) is provided.
2. **Directory Check**: Verifies that the target directories physically exist.
3. **Executes Pipeline**: Runs `build_runner` followed by `flutter gen-l10n` sequentially for each target.


## refresh

```bash
# Target a module
fsda refresh --module <module>

# Target an app
fsda refresh -a <app>

# Target both simultaneously
fsda refresh -m <module> -a <app>
```

Executes cleanup (`flutter clean`) and dependency refreshing (`flutter pub get`) sequentially.

### What Happens
1. **Validates Options**: Ensures at least one target (`--module` or `--app`) is provided.
2. **Directory Check**: Verifies that the target directories physically exist.
3. **Executes Cleanup & Fetch**: Runs `flutter clean` followed by `flutter pub get` sequentially for each target.


## fix-import

```bash
# Target a module
fsda fix-import --module <module>

# Target an app
fsda fix-import -a <app>

# Target both simultaneously
fsda fix-import -m <module> -a <app>
```

Fixes and organizes imports automatically inside the targeted module(s) or app(s).

### What Happens
1. **Validates Options**: Ensures at least one target (`--module` or `--app`) is provided.
2. **Directory Check**: Verifies that the target directory physically exists.
3. **Executes Import Fix**: Runs the import resolution command (`dart fix --apply`) sequentially for each target provided.