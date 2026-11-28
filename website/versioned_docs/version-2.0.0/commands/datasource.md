---
id: commands-datasource
title: Datasource
---

## ds-remote

```bash
fsda ds-remote "<base-path>" -f <feature> -m <module>
```

Generates a remote data source interface and implementation for an existing feature inside a target module.

### Naming & Path Constraints

* **Feature Name**: Must follow strict `snake_case` rules (e.g., `user_profile`, `payment_gateway`).
* **Base Path**: Must represent a valid API endpoint path string (e.g., `"/notes"`, `"/users/profile"`).

### Options

* `-f`, `--feature <name>`: **(Required)** Specifies the target feature name under `lib/src/features/` where the remote data source will be added.
* `-m`, `--module <name>`: **(Required)** Specifies the target module name inside the `modules/` directory.

### Workspace Guard

Must be executed inside an FSDA workspace root directory where `.fsda/config.yaml` is present. If executed outside, the command will abort immediately with an error.

### What Happens

1. **Validates Input & Options**: Checks whether the target feature exists, ensures required options (`-f` and `-m`) are provided, and validates that the remote data source files do not already exist.
2. **Scaffolds Remote Data Source**: Automatically creates:
* Remote data source interface (`<feature>_remote_data_source.dart`).
* Remote data source implementation (`<feature>_remote_data_source_impl.dart`) configured with the specified API base path.
3. **Automatic Code Injection**: Injects export statements for both files dynamically into the feature's barrel file under the `// data` checkpoint, and automatically injects the remote data source field, constructor parameter, and initializer into the feature's repository implementation (`*_repository_impl.dart`) using comment markers (skipping if the field already exists).
4. **Operation Report**: Displays a clean, structured terminal summary logging all generated files and injected exports.

### Rerun Behavior

* If the remote data source interface or implementation files already exist in the target feature, the command halts execution immediately with an error to prevent overwriting existing files.

---

## ds-local

```bash
fsda ds-local <cache_key> -f <feature> -m <module>
```

Generates a local data source interface and implementation for an existing feature inside a target module.

### Naming Constraints

* **Feature Name**: Must follow strict `snake_case` rules (e.g., `user_profile`, `payment_gateway`).
* **Cache Key**: Must follow strict `snake_case` format (e.g., `auth_token`, `theme_mode`).

### Options

* `-f`, `--feature <name>`: **(Required)** Specifies the target feature name under `lib/src/features/` where the local data source will be added.
* `-m`, `--module <name>`: **(Required)** Specifies the target module name inside the `modules/` directory.

### Workspace Guard

Must be executed inside an FSDA workspace root directory where `.fsda/config.yaml` is present. If executed outside, the command will abort immediately with an error.

### What Happens

1. **Validates Input & Options**: Checks whether the target feature exists, validates the `cache_key` format against strict `snake_case` rules, ensures required options are provided, and verifies that the local data source files do not already exist.
2. **Scaffolds Local Data Source**: Automatically creates:
* Local data source interface (`<feature>_local_data_source.dart`).
* Local data source implementation (`<feature>_local_data_source_impl.dart`) configured with the specified cache key.
3. **Automatic Code Injection**: Injects export statements for both files dynamically into the feature's barrel file under the `// data` checkpoint, and automatically injects the remote data source field, constructor parameter, and initializer into the feature's repository implementation (`*_repository_impl.dart`) using comment markers (skipping if the field already exists).
4. **Operation Report**: Displays a clean, structured terminal summary logging all generated files and injected exports.

### Rerun Behavior

* If the local data source interface or implementation files already exist in the target feature, the command halts execution immediately with an error to prevent overwriting existing files.
