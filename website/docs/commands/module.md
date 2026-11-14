---
id: commands-module
title: Module
---

## gen-module

```bash
fsda gen-module <name>
```

Generates a new module from the built-in brick template inside the FSDA CLI.

### Naming Constraints

* Format: Must follow strict `snake_case` rules (e.g., `user_profile`, `payment_gateway`).
* Validation: Names starting with numbers, containing hyphens, spaces, or uppercase letters will be rejected.

### Workspace Guard

Must be executed inside an FSDA workspace root directory where `fsda.yaml` is present. If executed outside, the command will abort immediately with an error.

### What Happens

1. Validates Input: Checks whether `<name>` complies with `snake_case` naming rules.
2. Directory Check: Ensures that a module with the same name does not already exist under `modules/`.
3. Module Generation: Scaffolds a complete Architecture module structure from the built-in Mason brick template, using the `sdk_version` specified in your `fsda.yaml`.
4. Automatic Dependencies Installation: Automatically executes `dart pub add` to install required dependencies (`freezed_annotation`, `json_annotation`, `bloc`) and dev dependencies (`flutter_lints`, `build_runner`, `freezed`, `json_serializable`).
5. Operation Report: Displays a clean, structured terminal summary logging all generated directories and files (excluding placeholder files like `.gitkeep` and generated artifacts like `*.freezed.dart` or `*.g.dart`).

### Rerun Behavior

- If a module directory with the same name already exists under `modules/`, the command halts execution immediately with an error and leaves existing files untouched.