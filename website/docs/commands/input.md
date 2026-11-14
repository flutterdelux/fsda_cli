---
id: commands-input
title: Input
---

## Input Generator Commands

```bash
fsda input-<type> <field> -f <feature> -m <module> [options]
```

Generates UI-layer input widget components tailored to the **Feature Slice Driven Architecture (FSDA)**. Each command automates field name validation, widget file scaffolding, automatic resolution and injection of custom data type imports, and module ARB localization entry injection.

---

## Supported Input Types & Sub-Commands

### 1. `input-text`

* **Description**: Generates a standard, pure text input field widget.
* **Syntax**:

```bash
fsda input-text <field> -f <feature> -m <module>
```

### 2. `input-text-area`

* **Description**: Generates a multi-line text input field widget.
* **Syntax**:

```bash
fsda input-text-area <field> -f <feature> -m <module> [--min <int>] [--max <int>]
```

* **Options**: Supports `--min` and `--max` line configurations (default: `3`).

### 3. `input-switch`

* **Description**: Generates a boolean switch input widget.
* **Syntax**:

```bash
fsda input-switch <field> -f <feature> -m <module>
```

### 4. `input-password`

* **Description**: Generates a secure password input field widget.
* **Syntax**:

```bash
fsda input-password <field> -f <feature> -m <module>
```

* **Details**: Includes a built-in stateful visibility toggle (*eye icon*) for obscuring and revealing text.

### 5. `input-qty`

* **Description**: Generates a numeric quantity input field widget.
* **Syntax**:

```bash
fsda input-qty <field> -f <feature> -m <module>
```

* **Details**: Includes action buttons for incrementing (`+`) and decrementing (`-`) the value.

### 6. `input-number`

* **Description**: Generates a numeric number input field widget with type-specific keyboard configurations and input formatters.
* **Syntax**:

```bash
fsda input-number <field> -f <feature> -m <module> [--type <type>]
```

* **Details**: Automatically adjusts numeric keyboards and text formatters based on the data type (`int`, `double`). Defaults to `int` if omitted.

### 7. `input-image`

* **Description**: Generates an image file picker input widget.
* **Syntax**:

```bash
fsda input-image <field> -f <feature> -m <module> [--type <type>]
```

* **Details**: Defaults to `NetworkFile` if the `--type` option is omitted.

### 8. `input-dropdown`

* **Description**: Generates a generic item dropdown input widget.
* **Syntax**:

```bash
fsda input-dropdown <field> -f <feature> -m <module> --type <type>
```

* **Requirement**: The `--type` option is **required**.
* **Reminder**: Displays a terminal notice upon generation reminding developers to adapt the data source items accordingly.

### 9. `input-dropdown-enum`

* **Description**: Generates an enum-backed dropdown input widget.
* **Syntax**:

```bash
fsda input-dropdown-enum <field> -f <feature> -m <module> --type <type>
```

* **Requirement**: The `--type` option is **required**.

### 10. `input-selector`

* **Description**: Generates a custom selection input widget (supports both single object and list modes).
* **Syntax**:

```bash
fsda input-selector <field> -f <feature> -m <module> --type <type> [--list]
```

* **Requirement**: The `--type` option is **required**.
* **Flag**: Use the `--list` flag to generate a multiple-selection/list-based selector widget.

---

## Naming Constraints & Validation

* **Field Format**: The `<field>` positional argument must strictly adhere to the standard field naming rules (`Rules.fieldNameRegExp`).
* **Fail-Fast**: If required arguments are missing, formatting fails, or the target widget file already exists, execution halts immediately with a usage or conflict error.

#### Examples

```bash
# Generate a standard text input
fsda input-text username -f profile -m user

# Generate a number input (default int)
fsda input-number age -f profile -m user

# Generate a decimal number input
fsda input-number price -f product -m catalog --type double

# Generate a text area with custom line constraints
fsda input-text-area address -f shipping -m order --min 2 --max 4

# Generate a dropdown with a custom model type
fsda input-dropdown category -f product -m catalog --type CategoryModel

# Generate a list-based selector for multiple items
fsda input-selector tags -f article -m blog --type TagModel --list

```

---

## Options

* `-f`, `--feature <name>`: **(Required)** Target feature name under `lib/src/features/`.
* `-m`, `--module <name>`: **(Required)** Target module name under `modules/`.
* `--type <type>`: *(Required for `input-dropdown`, `input-dropdown-enum`, `input-selector`; optional for `input-image`, `input-number`)* Specifies the underlying object, item, or numeric type of the input (default for `input-number`: `int`).
* `--min <int>`: *(Optional)* Minimum line count for `input-text-area` (default: `3`).
* `--max <int>`: *(Optional)* Maximum line count for `input-text-area` (default: `3`).
* `--list`: *(Optional)* Flag dedicated to `input-selector` to switch template generation to a list/multiple selection layout.

---

## Workspace Guard

Must be executed inside an FSDA workspace root directory where `fsda.yaml` is present. If executed outside, the command aborts immediately.

---

## What Happens

1. **Input Validation & Gate**: Employs the `InputGateCommand` and `InputGateParam` architectural wrapper to validate positional field arguments, check regex patterns, and confirm file absence.
2. **Widget Scaffolding**: Writes the appropriate widget template content to `lib/src/ui/features/<feature>/widgets/<feature>_<field>_field.dart`.
3. **Automatic Import Resolution**: Identifies specialized custom types (via `--type`) using `_importResolverService`, automatically injecting the correct `import` statements into the widget file.
4. **ARB Localization Injection**: Automatically inserts localization entries (labels, hints, validation keys) into the module's ARB files right before the feature's end divider marker (`<feature>EndDivider`).
5. **Unified Operation Report**: Displays a clean progress summary in the terminal followed by a detailed operation report.

---

## Rerun Behavior

* If the target widget file already exists on disk, the command halts execution immediately with an error and leaves existing files untouched.
