---
id: commands-failure
title: Failure
---

These commands inject and manage typed failures, exception factories, failure mapping extensions, and localization entries inside specific modules within your FSDA workspace.

---

## gen-failure

```bash
fsda gen-failure "<name>:<message>" -m <module>
```

Injects a new failure option into the target module's exception class, failure enum, localization extension, and ARB localization files.

### Naming Constraints

* **Format**: Failure name must follow strict `snake_case` according to the failure naming rules (e.g., `task_not_found`).
* **Argument Format**: Must be passed as a single string formatted as `"<name>:<message>"` (e.g., `"task_milestone_invalid_empty:Task milestone cannot be empty"`).
* **Validation**: Invalid formats or empty failure names/messages will be rejected immediately with an error.

### Options

* `-m`, `--module <name>`: **(Required)** Target module name under `modules/`.

### Workspace Guard

Must be executed inside an FSDA workspace root directory where `fsda.yaml` is present. If executed outside, the command will abort immediately with an error.

### What Happens

1. **Validates Inputs & Format**: Checks whether the target format `"<name>:<message>"` is valid and ensures that neither the name nor the default message is empty.
2. **File Existence Checks**: Verifies that the target module's exception file (`<module>_exception.dart`), failure enum file (`<module>_failure.dart`), and failure extension file (`<module>_failure_x.dart`) exist physically on disk.
3. **Injects Exception Methods**:
    * Injects a new factory constructor inside the module exception class.
    * Injects a new `message` getter entry inside `when(...)`.
    * Injects a new `toFailure()` mapping entry inside `when(...)`.
    * Injects a new API error code matcher entry inside `fromApiResponse()`.
4. **Injects Failure Enum Value**: Adds the new failure value to the module's failure enum.
5. **Injects Extension Mapper**: Adds a new localization entry inside the `localize` method of the module's failure extension.
6. **Automatic ARB Injection**: Injects localization keys and default message values into all ARB files (`lib/l10n/*.arb`) inside the target module before the end divider key.
7. **Operation Report**: Displays a clean terminal summary logging all modified files and injected localization entries.

### Rerun Behavior

> ⚠️ **WARNING**: `gen-failure` purely performs code injections and **does not create new artifact files**. Executing this command multiple times with the same `<name>:<message>` argument will result in **duplicate code injections** across your exception, failure enum, and extension files.

* If the target module's required files (`<module>_exception.dart`, `<module>_failure.dart`, `<module>_failure_x.dart`) do not exist, the command halts execution immediately with an error.
* If rerun on an existing setup, it will append duplicate entries to all target files without skipping previously injected names. Make sure to review or revert your changes if you accidentally rerun the command.