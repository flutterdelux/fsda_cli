---
id: commands-compose
title: Compose
---

# Compose Commands

These commands compose and scaffold presentation-layer UI wrapper artifacts (**Page**, **Section**, **Sheet**, **Dialog**, or custom widgets) inside a target application module (`apps/<app>/lib/modules/<module>/features/<feature>/`). Each command automatically inspects existing logic slices and atomic UI widgets to wire state management listeners, builders, and form controllers.

---

## Common Options & Target Resolution

All `compose-*` commands extend `ComposeGateCommand` and share the following core options and conventions:

* `-a`, `--app <name>`: **(Required)** Target application name inside `apps/`.
* `-m`, `--module <name>`: **(Required)** Target module name inside `modules/` and `apps/<app>/lib/modules/`.
* `-f`, `--feature <name>`: **(Required)** Target feature name inside the module.
* `--logic-flow <slice>`: **(Required)** Target flow-driven logic slice name (generated via `gen-logic-flow`).
* `-t`, `--target <name>`: **(Required)** Target artifact name in strict `snake_case`.

### Automatic Wrapper Detection

The wrapper type and destination directory are automatically resolved based on the suffix of the `--target` argument:

| Target Suffix | Wrapper Type | Destination Directory |
| :--- | :--- | :--- |
| **`_page`** | `Page` | `apps/<app>/lib/modules/<module>/features/<feature>/pages/` |
| **`_section`** | `Section` | `apps/<app>/lib/modules/<module>/features/<feature>/widgets/` |
| **`_sheet`** | `Sheet` | `apps/<app>/lib/modules/<module>/features/<feature>/widgets/` |
| **`_dialog`** | `Dialog` | `apps/<app>/lib/modules/<module>/features/<feature>/widgets/` |
| *(Other)* | Custom Widget | `apps/<app>/lib/modules/<module>/features/<feature>/widgets/` |

---

## compose-r

```bash
fsda compose-r -a <app> -m <module> -f <feature> --logic-flow <slice> --ui <slice> -t <target>
```

Composes and scaffolds a **retrieval** UI wrapper artifact that connects a retrieval logic slice (`gen-logic-flow r`) with standard UI presentation components (`gen-ui`, `gen-ui-lsv`, `gen-ui-lsh`).

### Additional Options

* `--ui <slice>`: **(Required)** Target UI slice name in `snake_case` containing the `_content` and `_skeleton` widgets.

### What Happens

1. **Validates Slices**: Verifies that both the `--logic-flow` slice and `--ui` slice directories exist in the source module.
2. **AST Metadata Inspection**:
   * Inspects the logic controller (`Cubit`, `GetX`, `Provider`, or `Riverpod`) to extract its state control type, constructor parameters, and trigger method.
   * Scans the `--ui` directory for `*_content.dart` and `*_skeleton.dart` widgets to extract their required parameters.
3. **Scaffolds Wrapper Artifact**: Generates the wrapper file in `pages/` or `widgets/` wired with state builders handling `.initial()`, `.loading()`, `.loaded()`, and `.failure()` states.
4. **Operation Report**: Logs the created wrapper file path.

### Example

```bash
fsda compose-r -a portal -m task -f task --logic-flow detail --ui detail -t task_detail_page
```

---

## compose-pag

```bash
fsda compose-pag -a <app> -m <module> -f <feature> --logic-flow <slice> --ui <slice> -t <target>
```

Composes and scaffolds a **pagination** UI wrapper artifact that connects a pagination logic slice (`gen-logic-flow pag`) with a paginated list UI slice (`gen-ui-pag`).

### Additional Options

* `--ui <slice>`: **(Required)** Target paginated UI slice name in `snake_case`.

### What Happens

1. **Validates Slices**: Verifies that both the `--logic-flow` slice and `--ui` slice directories exist in the source module.
2. **AST Metadata Inspection**: Extracts controller metadata (`init()`, `refresh()`, `loadMore()`) from the pagination logic slice.
3. **Scaffolds Wrapper Artifact**: Generates the wrapper file in `pages/` or `widgets/` wired with infinite scroll listeners, pull-to-refresh handlers, and pagination state builders.
4. **Operation Report**: Logs the created wrapper file path.

### Example

```bash
fsda compose-pag -a portal -m task -f task --logic-flow list --ui list -t task_list_page
```

---

## compose-m

```bash
fsda compose-m -a <app> -m <module> -f <feature> --logic-flow <slice> -t <target>
```

Composes and scaffolds a **mutation** UI wrapper artifact (such as a confirmation dialog, action sheet, or action widget) driven by a mutation logic slice (`gen-logic-flow m`).

### What Happens

1. **Validates Logic Flow Slice**: Verifies that the `--logic-flow` slice exists in the source module.
2. **AST Metadata Inspection**: Inspects the mutation logic controller to extract its execution method, parameter signature, and state control type.
3. **Scaffolds Wrapper Artifact**: Generates the wrapper file in `pages/` or `widgets/` configured with mutation listeners (handling `.loading()`, `.success()`, and `.failure()` feedback).
4. **Operation Report**: Logs the created wrapper file path.

### Example

```bash
fsda compose-m -a portal -m task -f task --logic-flow delete -t task_delete_dialog
```

---

## compose-form

```bash
fsda compose-form -a <app> -m <module> -f <feature> --logic-flow <slice> --logic <slice> --ui <slice> -t <target>
```

Composes and scaffolds a **form** UI wrapper artifact that integrates a mutation logic flow (`gen-logic-flow m`), a local form state logic (`gen-logic`), and an interactive form UI slice (`gen-ui-form`).

### Additional Options

* `--logic <slice>`: **(Required)** Target property-based logic slice name in `snake_case` managing form state.
* `--ui <slice>`: **(Required)** Target form UI slice name in `snake_case` generated via `gen-ui-form`.

### What Happens

1. **Validates Slices**: Verifies that `--logic-flow`, `--logic`, and `--ui` slice directories all exist in the source module.
2. **Dual AST Logic Inspection**:
   * Inspects `--logic-flow` to wire submission execution and mutation state feedback.
   * Inspects `--logic` to wire local form field state updates.
3. **Scaffolds Wrapper Artifact**: Generates the complete form wrapper in `pages/` or `widgets/`, binding the form UI widget with both logic controllers.
4. **Operation Report**: Logs the created wrapper file path.

### Example

```bash
fsda compose-form -a portal -m task -f task --logic-flow create --logic create_form --ui create -t task_create_sheet
```

---

## Workspace Guard & Rerun Behavior

### Workspace Guard

Must be executed inside an FSDA workspace root directory where `fsda.yaml` is present. If executed outside, the command aborts immediately with an error.

### Rerun Behavior

* If the target file already exists at the resolved `pages/` or `widgets/` destination path, the command halts execution immediately with an error to prevent accidental overwrites.