---
id: commands-logic
title: Logic
---

These commands manage and generate feature slice state management components using **Cubit** (default) and **Freezed State** pairs across architectural layers.

---

## gen-logic

```bash
fsda gen-logic -m <module> -f <feature> -s <slice> -p "<type>:<name>[:default]" [-c <control>]
```

Generates a simple, property-based state management component (Cubit by default or specified state control) and Freezed State pair. This command is designed for basic state management where state is primarily updated via state properties without needing direct Use Case flow integrations.

### Options

* `-s`, `--slice <name>`: **(Required)** Feature slice name in `snake_case` (e.g., `filter`, `form_input`).
* `-p`, `--prop <property>`: **(Required)** Defines a property using the format `Type:name[:defaultValue]`. This is a multi-flag option (`--prop`), meaning you can call it multiple times to add several properties cleanly (e.g., `--prop "String:search_query" --prop "bool:is_active:false"`).
* `-f`, `--feature <name>`: **(Required)** Target feature name under `lib/src/features/`.
* `-m`, `--module <name>`: **(Required)** Target module name under `modules/`.
* `-c`, `--control <control>`: *(Optional)* State control / state management approach (`cubit`, `getx`, `provider`, `riverpod`). Defaults to `cubit`.

### Examples

```bash
# Generate a property-based Cubit using multi-flag --prop
fsda gen-logic -s filter -f task -m todo \
  --prop "String:search_query" \
  --prop "bool:is_active:false" \
  -c cubit
```

### What Happens

1. **Validates Inputs & Options**: Ensures mandatory parameters (`--slice`, `--prop`) are provided and formatted properly.
2. **State & Cubit Scaffolding**: Generates:
* Freezed State file with declared properties and default values (`<feature>_<slice>_state.dart`).
* Cubit/Controller class with individual update methods for each property (`<feature>_<slice>_<control_suffix>.dart`).


3. **Barrel Export Injection**: Automatically exports both files in the feature barrel (`<feature>_feature.dart`) under the `// logic` checkpoint.

### Workspace Guard

Must be executed inside an FSDA workspace root directory where `.fsda/config.yaml` is present.

### Rerun Behavior

* If the logic file already exists in the target feature slice directory, commands halt execution immediately to prevent accidental overwrites.

---

## gen-logic-flow

```bash
fsda gen-logic-flow -m <module> -f <feature> -s <slice> -t <type> --uc <usecase> [-c <control>]
```

Generates a flow-driven logic component (Cubit by default or specified state control) and Freezed State pair integrated directly with a Use Case. It inspects the target Use Case to analyze method signature, parameters, return types, and execution model (Async, Sync, or Stream), automatically handling state mappers, lifecycle, and barrel exports.

### Supported Logic Flow Types (`<type>`)

* **`m`** (*mutation*): Used for state-modifying actions (e.g., create, update, delete). Generates `.initial()`, `.loading()`, `.success()`, and `.failure()` state variants.
* **`r`** (*retrieval*): Used for fetching single-source data. Stores parameters internally within the component for easy retry/refresh operations. Generates `.initial()`, `.loading()`, `.loaded()`, and `.failure()` state variants.
* **`pag`** (*pagination*): Tailored for paginated list retrieval. Generates `init()`, `refresh()`, `loadMore()`, automatic page incrementing, and `hasReachedMax` checks.

### Use Case Adaptation

* **Execution Flow**: Detects if the target Use Case is asynchronous (`Future`), synchronous, or a `Stream`. For stream-based Use Cases, it automatically injects `StreamSubscription` lifecycle management and cleans up resources inside `close()`.
* **Parameter & Return Signature**: Automatically shapes method signatures, internal parameter storage fields, and state mapper contracts based on Use Case AST analysis.

### Examples

```bash
# Generate a mutation Cubit for task creation (default control: cubit)
fsda gen-logic-flow -t m -s create --uc task_create_use_case -f task -m todo

# Generate a retrieval logic with explicit control state
fsda gen-logic-flow -t r -s detail --uc task_detail_use_case -f task -m todo -c cubit

# Generate a pagination Cubit
fsda gen-logic-flow -t pag -s list --uc task_list_use_case -f task -m todo

# Generate a stream listener Cubit (handles StreamSubscription & cleanup)
fsda gen-logic-flow -t r -s status_listen --uc task_status_listen_use_case -f task -m todo
```

### Options

* `-t`, `--type`: **(Required)** Logic flow type (`m`, `r`, or `pag`).
* `-s`, `--slice <name>`: **(Required)** Feature slice name in `snake_case` (e.g., `create`, `list`).
* `--uc <usecase>`: **(Required)** Target Use Case name ending with `_use_case` (e.g., `task_create_use_case`).
* `-f`, `--feature <name>`: **(Required)** Target feature name under `lib/src/features/`.
* `-m`, `--module <name>`: **(Required)** Target module name under `modules/`.
* `-c`, `--control <control>`: *(Optional)* State control / state management approach (`cubit`, `getx`, `provider`, `riverpod`). Defaults to `cubit`.

### Workspace Guard

Must be executed inside an FSDA workspace root directory where `.fsda/config.yaml` is present.

### Rerun Behavior

* If the logic file already exists in the target feature slice directory, commands halt execution immediately to prevent accidental overwrites.