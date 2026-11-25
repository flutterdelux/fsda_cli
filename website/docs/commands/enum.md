---
id: commands-enum
title: Enum
---

## gen-enum

```bash
fsda gen-enum -n <name> -v "<value_1>,<value_2>,..." -f <feature> -m <module> [--lower]
```

Generates a complete Enum structure (including data converters and UI extensions) and automatically injects exports and localization entries into the target feature and module.

### Naming Constraints

* **Format**: Must be in strict `snake_case` (e.g., `payment_method`, `role`).
* **Validation**: Invalid names will be rejected immediately with an error.

### Options

* `-v`, `--values <values>`: **(Required)** Comma-separated enum values (e.g., `--values cashier,admin_backoffice,owner`).
* `-f`, `--feature <name>`: **(Required)** Target feature name under `lib/src/features/`.
* `-m`, `--module <name>`: **(Required)** Target module name under `modules/`.
* `--lower`: *(Optional)* Sets the generated converter constants to lowercase `snake_case` (e.g., `'in_progress'`). By default (`false`), uppercase `SCREAMING_SNAKE_CASE` constants (e.g., `'IN_PROGRESS'`) are used.

### Examples

```bash
fsda gen-enum -n task_status -v "in_progress,completed" -f task -m todo
fsda gen-enum -n task_status -v "in_progress,completed" -f task -m todo --lower
```

### Workspace Guard

Must be executed inside an FSDA workspace root directory where `fsda.yaml` is present. If executed outside, the command will abort immediately with an error.

### What Happens

1. **Validates Inputs & Options**: Checks whether all required arguments (`--values`, `--feature`, `--module`) are provided and comply with their respective validation rules.
2. **Directory & Existence Checks**: Verifies that the target module and feature exist physically on disk, and ensures that an enum with the same name does not already exist.
3. **Scaffolds Enum Files**: Automatically creates:
    * Enum file under `domain/enums/<name>.dart`.
    * Converter file under `data/converters/<name>_converter.dart` (respecting the `--lower` casing flag).
    * UI extension file under `ui/shared/extensions/<name>_x.dart`.
4. **Automatic Code Injection**: Injects export statements dynamically into the feature barrel file (`<feature>_feature.dart`) under the `// domain` and `// ui` checkpoints.
5. **Automatic ARB Injection**: Scans the module's localization files (`lib/l10n/*.arb`) and automatically inserts localization entries right before the feature's end divider key (`<feature>EndDivider`).
6. **Operation Report**: Displays a clean terminal summary logging all created files and injected ARB entries.

### Rerun Behavior

* If an enum file with the same name already exists inside the target feature, the command halts execution immediately with an error and leaves existing files untouched.

---

## rm-enum

```bash
fsda rm-enum -n <name> -f <feature> -m <module>
```

Removes an existing Enum structure, including its converter, UI extension, barrel export declarations, and localization entries.

### Naming Constraints

* **Format**: Must be in strict `snake_case` (e.g., `payment_method`, `role`).
* **Validation**: Invalid names will be rejected immediately with an error.

### Options

* `-f`, `--feature <name>`: **(Required)** Target feature name under `lib/src/features/`.
* `-m`, `--module <name>`: **(Required)** Target module name under `modules/`.

> **Note**: Do not pass `--values` to `rm-enum`. The command automatically reads the values from the existing enum file to clean up corresponding localization keys without leaving orphans.

### Workspace Guard

Must be executed inside an FSDA workspace root directory where `fsda.yaml` is present. If executed outside, the command will abort immediately with an error.

### What Happens

1. **Validates Target Existence**: Verifies that the module, feature, and target enum file exist physically on disk before taking action.
2. **Reads Existing Values**: Inspects the existing enum file to extract all declared values, mapping them back to their original `snake_case` identifiers.
3. **Localization Cleanup**: Scans all ARB files (`lib/l10n/*.arb`) inside the target module and removes every corresponding localization label and description entry.
4. **Removes Extensions & Uninjects Exports**: Deletes the UI extension file (`<name>_x.dart`) and uninjects its export path from the feature barrel (`<feature>_feature.dart`).
5. **Removes Converter**: Deletes the JSON converter file (`<name>_converter.dart`).
6. **Removes Enum File & Uninjects Exports**: Deletes the main enum file (`<name>.dart`) and uninjects its export path from the feature barrel.
7. **Operation Report**: Displays a terminal summary logging all deleted files and uninjected entries.

### Rerun Behavior

* If the specified enum file does not exist inside the target feature, the command halts execution immediately with an error and takes no action.