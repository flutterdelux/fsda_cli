---
id: commands-feature
title: Feature
---

## gen-feature

```bash
fsda gen-feature <feature> -m <module>
```

Generates a complete FSDA Architecture feature layer structure automatically inside the target module directory (`modules/<module>/lib/src/features/`).

### Naming Constraints

* **Format**: Must follow strict `snake_case` rules (e.g., `user_profile`, `payment_gateway`).
* **Validation**: Names starting with numbers, containing hyphens, spaces, or uppercase letters will be rejected immediately with an error.

### Options

* `-m`, `--module <name>`: **(Required)** Specifies the target module name inside the `modules/` directory where the feature will be created.

### Workspace Guard

Must be executed inside an FSDA workspace root directory where `fsda.yaml` is present. If executed outside, the command will abort immediately with an error.

### What Happens

1. **Validates Input & Options**: Checks whether `<feature>` and `<module>` comply with `snake_case` naming rules and ensures the required `--module` option is provided.
2. **Directory Checks**: Verifies that the target module physically exists on disk and ensures that a feature with the same name does not already exist.
3. **Scaffolds Architecture Layers**: Automatically creates the complete directory structure:
* `data/` containing subfolders: `converters`, `datasources`, `dtos`, `repositories`, `requests`, `responses`.
* `domain/` containing subfolders: `entities`, `enums`, `params`, `repositories`, `usecases`.
* Empty presentation and logic folders: `logic/` and `ui/`.
4. **Generates Feature Barrel File**: Creates `<feature>_feature.dart` containing checkpoint comments (`// data`, `// domain`, `// logic`, `// ui`) for dynamic exports.
5. **Generates Repositories**: Scaffolds repository contracts and repository implementations from built-in templates.
6. **Automatic Code Injection**: Injects export statements dynamically into the feature barrel file under their respective checkpoints and inject export feature barrel inside the parent module's barrel file.
7. **Automatic ARB Template Injection**: Scans for ARB files in the module's localization directory (`lib/l10n/<module>_*.arb`) and automatically injects feature divider markers (`@<feature>StartDivider`, `<feature>Label`, `@<feature>EndDivider`) to streamline localization development.
8. **Operation Report**: Displays a clean, structured terminal summary logging all generated directories, files, and injected exports.

### Rerun Behavior

* If a feature directory with the same name already exists under `modules/<module>/lib/src/features/`, the command halts execution immediately with an error and leaves existing files untouched.

---

## rm-feature

```bash
fsda rm-feature <feature> -m <module>
```

Removes an existing FSDA Architecture feature structure and cleans up all associated configurations from a target module.

### Naming Constraints

* **Format**: Must follow strict `snake_case` rules (e.g., `user_profile`, `payment_gateway`).
* **Validation**: Names starting with numbers, containing hyphens, spaces, or uppercase letters will be rejected immediately with an error.

### Options

* `-m`, `--module <name>`: **(Required)** Specifies the target module name under `modules/` where the feature resides.


### Workspace Guard

Must be executed inside an FSDA workspace root directory where `fsda.yaml` is present. If executed outside, the command will abort immediately with an error.

### What Happens

1. **Validates Input & Options**: Checks whether `<feature>` and `<module>` comply with `snake_case` naming rules and ensures the required `--module` option is provided.
2. **Existence Checks**: Verifies that both the target module directory and the specific feature directory physically exist on disk; otherwise, execution halts with an error.
3. **Removes Feature Directory**: Safely deletes the entire feature directory from `modules/<module>/lib/src/features/<feature>`.
4. **Removes Module Barrel Export**: Automatically removes the feature's export statement from the parent module's barrel file (`lib/<module>.dart`).
5. **Removes ARB Entries**: Scans the module's localization files (`lib/l10n/*.arb`) and automatically cleans up/removes all associated localization keys and markers for the feature.
6. **Operation Report**: Displays a clean terminal summary logging all deleted paths, unjected exports, and removed localization keys.



### Rerun Behavior

* If the target module or the feature directory does not exist, the command halts execution immediately with an error and takes no action.
