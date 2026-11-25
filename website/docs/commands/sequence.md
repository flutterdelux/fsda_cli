---
id: commands-sequence
title: Sequence
---

These commands manage and wire complete data-to-domain operation sequences across architectural layers, covering **Use Case**, **Repository** (Interface & Implementation), and **Data Source** (Interface & Implementation).

---

## gen-sequence

```bash
fsda gen-sequence -f <feature> -m <module> --act <action> --uc <usecase> -d <method> [--flow <flow_type>] [--ds <mode>] [--list] [--model <model> ...]
```

Generates and wires a complete data-to-domain operation sequence in a single execution. It automatically injects the required method signatures/bodies, resolves and sorts model imports, generates localization strings, and updates barrel files.

### Supported Actions (`<action>`)

The sequence command accepts standard HTTP-like action verbs as the primary argument:

* **`post`**: Typically used for creating/submitting data.
* **`get`**: Typically used for fetching data (supports single items or lists).
* **`put`**: Typically used for full resource updates.
* **`patch`**: Typically used for partial resource updates.
* **`delete`**: Typically used for removing resources or clearing local data.

### Model Combinations (`--model`)

Models are specified using flexible suffix-based identifiers (`_response`, `_dto`, `_entity`, `_request`, `_param`). They can be listed in **any order**, and each suffix can only be specified **at most once per command**.

Depending on the operation type, different model combinations are supported:

* **Return + Param**: Requires both a response/DTO model and an entity/request/param model.
* **Return**: Requires a response/DTO model and an entity model (without request/param).
* **Param**: Requires request and param models (without return models).
* **Void**: No models are required (pure execution).

#### Examples

```bash
# Post with Return and Param models
fsda gen-sequence -f task -m todo --act post --uc task_create_use_case -d create_task --model task_create_response --model task_dto --model task_entity --model task_create_request --model task_create_param

# Get with List flag and Return models
fsda gen-sequence -f task -m todo --act get --uc task_list_use_case -d get_task_list --list --model task_list_response --model task_dto --model task_entity

# Void action targeting local data source
fsda gen-sequence -f note -m todo --act delete --uc note_clear_use_case -d clear_note --ds local
```

### Options

* `-f`, `--feature <name>`: **(Required)** Target feature name under `lib/src/features/`.
* `-m`, `--module <name>`: **(Required)** Target module name under `modules/`.
* `--act <action>`: **(Required)** Operation action: `post`, `get`, `put`, `patch`, or `delete`.
* `--uc <usecase>`: **(Required)** Use case name in strict `snake_case` ending with `_use_case` (e.g., `task_create_use_case`).
* `-d`, `--method <name>`: **(Required)** Repository and data source method name in strict `snake_case` (e.g., `create_task`).
* `--flow <flow_type>`: *(Optional)* Execution flow type. Allowed values: `async` (default), `sync`, or `stream`.
* `--ds <mode>`: *(Optional)* Data source mode. Allowed values: `remote` (default) or `local`.
* `--list`: *(Optional)* Flag indicating if the return type is a `List` of entities or DTOs.
* `--model <model>`: *(Optional, repeatable)* Model name. Provide one flag per model, using a supported suffix (`_response`, `_dto`, `_entity`, `_request`, `_param`).

### Workspace Guard

Must be executed inside an FSDA workspace root directory where `.fsda/config.yaml` is present.

### What Happens

1. **Validates Inputs & Options**: Checks mandatory parameters (`--uc`, `--method`), enforces the `_use_case` suffix requirement, verifies strict `snake_case` naming rules, parses action verbs, and validates flexible model suffixes with duplicate protection.
2. **Automated Method Injection**: Analyzes target class declarations and safely inserts method signatures or implementation bodies into Data Source and Repository (Interface & Implementation).
3. **Smart Import Resolution & Sorting**: Automatically calculates relative paths for required models, inserts missing import directives, and formats them in clean, sorted tiers.
4. **Use Case Scaffolding**: Generates the Use Case class file and exports it into the feature barrel file under the `// domain` checkpoint.
5. **ARB Localization Injection**: Automatically injects localization entries for the new use case action into the module's ARB files before the feature's end divider key.
6. **Operation Report**: Displays a terminal summary detailing all injected methods, modified files, added imports, and updated ARB entries.

### Rerun Behavior

* If the target use case file (`<usecase>.dart`) already exists, or if the specified method signature already exists within the repository/datasource interfaces, the command halts execution immediately with an error and leaves existing files untouched.

---

## rm-sequence

```bash
fsda rm-sequence -f <feature> -m <module> --uc <usecase> -d <method> --ds <mode>
```

Removes an existing data-to-domain sequence by cleaning up associated use cases, un-wiring repository and data source methods, and cleaning up localization entries.

### Options

* `-f`, `--feature <name>`: **(Required)** Target feature name under `lib/src/features/`.
* `-m`, `--module <name>`: **(Required)** Target module name under `modules/`.
* `--uc <usecase>`: **(Required)** Use case name in strict `snake_case` ending with `_use_case` (e.g., `task_create_use_case`).
* `-d`, `--method <name>`: **(Required)** Repository and data source method name to uninject/remove.
* `--ds <mode>`: **(Required)** Data source mode where the method resides. Allowed values: `remote` or `local`.

### Workspace Guard

Must be executed inside an FSDA workspace root directory where `.fsda/config.yaml` is present.

### What Happens

1. **Validates Inputs & Options**: Checks mandatory options (`--uc`, `--method`, `--ds`), enforces the `_use_case` suffix requirement, validates naming formats, and ensures target use case and datasource files exist physically on disk.
2. **Method Uninjection**: Automatically removes the specified method declarations from Data Source and Repository (Interface & Implementation) files, leaving existing shared imports untouched.
3. **Use Case & Barrel Cleanup**: Deletes the target use case file from `domain/usecases/` and removes its export line from the feature's barrel file (`// domain`).
4. **ARB Localization Cleanup**: Scans the module's ARB files and removes corresponding localization entries for the use case.
5. **Operation Report**: Displays a terminal summary detailing all uninjected methods, deleted use case files, and cleaned localization keys.

### Rerun Behavior

* If the specified use case file or target data source files do not exist inside the target feature, the command halts execution immediately with an error and takes no action.
