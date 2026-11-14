---
id: commands-ui
title: UI
---

# UI Commands

The UI generator commands in FSDA CLI focus exclusively on producing atomic UI presentation components, parts, skeleton loaders, and feedback state variants at the module/feature level.

---

## gen-ui

```bash
fsda gen-ui -s <slice> -f <feature> -m <module> --model <model>
```

Generates standard UI components for a feature slice, including the content widget, skeleton loader, and error feedback handler.

### Options

* `-s`, `--slice <name>`: **(Required)** Target slice name in `snake_case` (e.g., `detail`, `summary`).
* `-f`, `--feature <name>`: **(Required)** Target feature name under `lib/src/features/`.
* `-m`, `--module <name>`: **(Required)** Target module name under `modules/`.
* `--model <model>`: **(Required)** Model name in strict `snake_case` ending with `_entity` or `_param` (e.g., `product_entity`, `task_create_param`) used by the UI content component.

### Examples

```bash
fsda gen-ui -s detail -f product -m catalog --model product_entity
```

---

## gen-ui-form

```bash
fsda gen-ui-form -s <slice> -f <feature> -m <module> --model <model> --fields "<fields>" [--initial]
```

Generates an interactive form widget for a feature slice complete with adaptive input controllers, value notifiers, validation logic, and localization injections.

### Properties Syntax (`--fields`)

Form fields are passed as a comma-separated string using colon (`:`) delimiters:

```bash
--fields "<input_type_1>:<value_type_1>:<field_name_1>:<default_value_1>,<input_type_2>:<value_type_2>..."
```

* **`<input_type>`**: **(Required)** Input control type (e.g., `text`, `number`, `password`, `dropdown`, `dropdown_enum`, `selector`, `selectorList`, `swich`, `image`, `qty`, `textArea`).
* **`<value_type>`**: **(Required)** Dart data type for the input value (e.g., `String`, `int`, `double`, `TaxType`). Append `?` for nullable types.
* **`<field_name>`**: **(Required)** Field name in `snake_case` (e.g., `user_name`, `tax_type`).
* **`<default_value>`**: *(Optional)* Default value applied to the controller or value notifier initializer.

### Options

* `-s`, `--slice <name>`: **(Required)** Target slice name.
* `-f`, `--feature <name>`: **(Required)** Target feature name.
* `-m`, `--module <name>`: **(Required)** Target module name.
* `--model <model>`: **(Required)** Model name in strict `snake_case` ending with `_entity` or `_param` representing the form result model (e.g., `product_entity`, `user_input_param`).
* `--fields "<fields>"`: **(Required)** Comma-separated input fields specifications.
* `--initial`: *(Optional)* Flag indicating whether the generated form accepts an initial data state.

### Examples

```bash
fsda gen-ui-form -s create -f catalog -m store --model product_entity --fields "text:String:title,number:double:price:0.0,dropdown_enum:TaxType:tax_type" --initial
```

---

## gen-ui-lsh

```bash
fsda gen-ui-lsh -s <slice> -f <feature> -m <module> --model <model>
```

Generates a horizontal list view slice (ideal for carousels, banners, or card streams) along with item parts, item skeletons, content, skeleton loaders, error feedback, and empty feedback variants.

### Options

* `-s`, `--slice <name>`: **(Required)** Target slice name.
* `-f`, `--feature <name>`: **(Required)** Target feature name.
* `-m`, `--module <name>`: **(Required)** Target module name.
* `--model <model>`: **(Required)** Model name in strict `snake_case` ending with `_entity` or `_param` for each item inside the horizontal list (e.g., `banner_entity`).

### Examples

```bash
fsda gen-ui-lsh -s banner_slider -f home -m dashboard --model banner_entity
```

---

## gen-ui-lsv

```bash
fsda gen-ui-lsv -s <slice> -f <feature> -m <module> --model <model>
```

Generates a standard vertical list view slice with separated item parts, item skeletons, content, skeleton loaders, error feedback, and empty feedback widgets.

### Options

* `-s`, `--slice <name>`: **(Required)** Target slice name.
* `-f`, `--feature <name>`: **(Required)** Target feature name.
* `-m`, `--module <name>`: **(Required)** Target module name.
* `--model <model>`: **(Required)** Model name in strict `snake_case` ending with `_entity` or `_param` for items in the vertical list (e.g., `order_entity`).

### Examples

```bash
fsda gen-ui-lsv -s recent -f order -m store --model order_entity
```

---

## gen-ui-pag

```bash
fsda gen-ui-pag -s <slice> -f <feature> -m <module> --model <model>
```

Generates a vertical list view slice featuring built-in pagination (infinite scrolling using a 90% scroll threshold and pull-to-refresh handling via `RefreshIndicator.adaptive`).

### Options

* `-s`, `--slice <name>`: **(Required)** Target slice name.
* `-f`, `--feature <name>`: **(Required)** Target feature name.
* `-m`, `--module <name>`: **(Required)** Target module name.
* `--model <model>`: **(Required)** Model name in strict `snake_case` ending with `_entity` or `_param` for items managed under pagination (e.g., `product_entity`).

### Examples

```bash
fsda gen-ui-pag -s catalog -f product -m store --model product_entity
```

---

## Workspace Guard & Rerun Behavior

### Workspace Guard

Must be executed inside an FSDA workspace root directory where `fsda.yaml` is present. If executed outside, the command will abort immediately with an error.

### Rerun Behavior

* If any of the target UI artifact files already exist inside the destination directory, the command halts execution immediately with an error (fail-fast) and leaves existing files untouched to prevent unintended overwrites.

### What Happens

1. **Validates Inputs & Options**: Checks whether required options (`--model`, `--fields`, `--module`, `--feature`) are provided, validates `--model` against strict `snake_case` rules and `_entity`/`_param` suffixes, and parses field strings immediately using fail-fast validation.
2. **Smart Auto-Import Resolution**: Resolves and organizes required imports automatically for built-ins, local dependencies, and shared packages (`app_core`, `app_ui`, `app_l10n`).
3. **Scaffolds UI Artifacts**: Generates widget content, parts, skeletons, and feedback files under the `ui/<slice>/widgets/` directory structure.
4. **Automatic Barrel Export**: Automatically injects export statements for primary variant files into the feature barrel file (`<feature>_feature.dart`) under the `// ui` checkpoint.
5. **Automatic ARB Injection**: Inserts localization entries (titles, error messages, empty messages, form validation notes) into the module's ARB files right before the feature's end divider key (`<feature>EndDivider`).
6. **Unified Operation Report**: Displays a consolidated terminal summary detailing all created files and injected export/ARB definitions.
