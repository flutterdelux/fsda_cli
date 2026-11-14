---
id: commands-model
title: Model
---


## gen-model

```bash
fsda gen-model <name_type> --props "<props>" -f <feature> -m <module> [--l10n] [--with-dto] [--with-request]
```

Generates a Freezed-backed data model class tailored to its architectural layer. The model type is automatically detected from the suffix of the model name (e.g., `_entity`, `_dto`, `_request`, `_param`, `_response`). It automatically handles property annotations, default values, JSON serialization, auto-importing local/global dependencies, barrel file exports, optional paired model creation, and localization entries.

### Supported Model Types & Suffixes

| Suffix | Target Layer & Directory | Generated Class Pattern | Special Behavior |
| --- | --- | --- | --- |
| **`_entity`** | `domain/entities/` | `XxxEntity` | Pure Freezed model. Auto-exported to feature barrel. Supports `--l10n` and `--with-dto`. |
| **`_param`** | `domain/params/` | `XxxParam` | Pure Freezed model. Auto-exported to feature barrel. Supports `--with-request`. |
| **`_dto`** | `data/dtos/` | `XxxDto` | Freezed + JsonSerializable. Includes `fromEntity()` and `toEntity()` converters. |
| **`_request`** | `data/requests/` | `XxxRequest` | Freezed + JsonSerializable. Includes `fromParam()` and `toParam()` converters. |
| **`_response`** | `data/responses/` | `XxxResponse` | Freezed + JsonSerializable with `fromJson`. |

### Naming Constraints

* **Format**: Must follow strict `snake_case` combining a base name and a valid type suffix (e.g., `task_entity`, `user_profile_dto`, `payment_transaction_response`).
* **Validation**: Names without a valid type suffix or single-word names (like `entity` or `task`) will be rejected immediately with an error.

### Properties Syntax (`--props`)

Properties are passed as a comma-separated string using colon (`:`) delimiters:

```bash
--props "<type_1>:<name_1>:<default_1>:<Converter1>,<type_2>:<name_2>..."
```

* **`<type>`**: Dart type (e.g., `String`, `int`, `DateTime`, `Uint8List`, `TaskStatus`). Append `?` for nullable types.
* **`<name>`**: **(Required)** Property name in `snake_case` (e.g., `created_at`). Converted to `camelCase` in generated Dart code.
* **`<default>`**: *(Optional)* Default value applied via Freezed's `@Default(...)` annotation. When omitted, non-nullable fields are marked `required`.
* **`<Converter>`**: *(Optional)* Custom converter class in `PascalCase` (e.g., `UtcDateTimeConverter`).

> **Note**: Converters are applied exclusively to data layer models (`dto`, `request`, `response`). When generating domain models (`entity` or `param`), specified converters are automatically omitted from the generated domain class while remaining intact for paired data models.

#### Examples

```bash
# Simple Entity with L10n
fsda gen-model task_entity --props "String:id,String:title,bool:is_completed:false" -f task -m todo --l10n

# Generate Paired Entity & DTO simultaneously
fsda gen-model task_entity --with-dto --props "String:id,TaskStatus:status:TaskStatus.pending,DateTime:created_at::UtcDateTimeConverter" -f task -m todo
```

### Options

* `-p`, `--props "<props>"`: **(Required)** Comma-separated property specifications.
* `-f`, `--feature <name>`: **(Required)** Target feature name under `lib/src/features/`.
* `-m`, `--module <name>`: **(Required)** Target module name under `modules/`.
* `--l10n`: *(Optional)* Injects localization keys for the model and its properties into module ARB files. Only supported for `_entity` models.
* `--with-dto`: *(Optional)* Automatically generates a matching `_dto` model alongside the primary `_entity` model in a single execution. Only supported for `_entity` models.
* `--with-request`: *(Optional)* Automatically generates a matching `_request` model alongside the primary `_param` model in a single execution. Only supported for `_param` models.

### Workspace Guard

Must be executed inside an FSDA workspace root directory where `fsda.yaml` is present. If executed outside, the command will abort immediately with an error.

### What Happens

1. **Validates Inputs & Options**: Checks whether required options (`--props`, `--module`, `--feature`) are provided, validates model name suffixes, and verifies paired flag rules (`--with-dto` only for entities, `--with-request` only for params).
2. **Directory & Fail-Fast Existence Checks**: Verifies that the target module and feature exist physically on disk, and ensures that neither the primary model nor the paired model file already exists.
3. **Smart Auto-Import Resolution**: Automatically resolves and organizes required imports without manual intervention for both primary and paired models:
    * **Dart Built-ins**: Ignores `dart:core` types; automatically adds `import 'dart:typed_data';` or `import 'dart:io';` for special types.
    * **Global Dependencies**: Resolves shared classes defined in `fsda.yaml` under `import_types_related_to.app_core`.
    * **Local Dependencies**: Automatically scans local `enums`, `entities`, `params`, `dtos`, `requests`, `responses`, and `converters` directories within the feature and resolves relative import paths.
    * **Import Ordering**: Sorts imports systematically into 3 distinct tiers (`dart:*` $\rightarrow$ `package:*` $\rightarrow$ relative paths `../`).
4. **Scaffolds Model Files**: Generates Freezed class structures for specified target models.
5. **Automatic Barrel Export**: Automatically injects export statements into the feature barrel file (`<feature>_feature.dart`) under the `// domain` checkpoint (for `_entity` and `_param` models).
6. **Automatic ARB Injection** *(when `--l10n` is enabled)*: Inserts model title and property localization entries into the module's ARB files right before the feature's end divider key (`<feature>EndDivider`).
7. **Unified Operation Report**: Displays a consolidated terminal summary listing all created files, barrel exports, and injected ARB entries across generated models.

### Rerun Behavior

* If a model file (or its paired target file) already exists inside the target directory, the command halts execution immediately with an error and leaves existing files untouched.

---

## rm-model

```bash
fsda rm-model <name_type> -f <feature> -m <module>
```

Removes an existing model file along with its generated part files (`.freezed.dart`, `.g.dart`), cleans up barrel file exports (for entities and params), and automatically uninjects associated localization keys from the module's ARB files based on the model properties prior to deletion.

### Naming & Arguments

* **`<name_type>`**: The complete model name containing its base name and type suffix (e.g., `task_entity`, `task_dto`).
* **Validation**: Must follow strict `snake_case` with a valid type suffix (`entity`, `param`, `dto`, `request`, `response`). Single-word arguments or invalid formats will be rejected.

### Options

* `-f`, `--feature <name>`: **(Required)** Target feature name under `lib/src/features/`.
* `-m`, `--module <name>`: **(Required)** Target module name under `modules/`.

#### Examples

```bash
# Remove an Entity and clean up its ARB keys & barrel exports
fsda rm-model task_entity -f task -m todo

# Remove a DTO
fsda rm-model task_dto -f task -m todo
```

### Workspace Guard

Must be executed inside an FSDA workspace root directory where `fsda.yaml` is present.

### What Happens

1. **Validates Inputs & Existence**: Ensures the model name format is correct, verifies that the target module and feature directories exist, and checks that the target model file is present on disk.
2. **Property Inspection**: Reads the model file to identify existing property names before deletion, ensuring accurate cleanup of localization keys.
3. **File Cleanup**: Deletes the primary model file and any associated generated part files (`.freezed.dart`, `.g.dart`).
4. **Barrel Uninjection**: Automatically removes the corresponding `export` statement from the feature barrel file (`<feature>_feature.dart`) for `_entity` and `_param` types.
5. **ARB Uninjection**: Removes the model and property localization entries from the module's ARB files.
6. **Operation Report**: Displays a terminal summary detailing removed files, un-injected exports, and cleaned ARB entries.

### Rerun Behavior

* If the target model file does not exist, the command halts execution immediately with an error.
