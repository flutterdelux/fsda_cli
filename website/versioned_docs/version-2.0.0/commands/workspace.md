---
id: commands-workspace
title: Workspace
---

## create

```bash
fsda create <workspace_name>
```

Creates a new FSDA workspace wrapper structure with baseline directories and standard configuration.

> Note: This command should be executed outside of an existing workspace directory to initialize a brand-new FSDA project root.

### Naming Constraints

- **Format**: Must follow `snake_case` rules (e.g., `my_workspace_app`, `core_workspace`).
- **Validation**: Names starting with numbers, containing hyphens, spaces, or uppercase letters will be rejected.

### What Happens

1. **Validates Input**: Checks whether `<workspace_name>` complies with `snake_case` naming rules.
2. **Directory Initialization**: Creates empty foundational directories:
   - `<workspace_name>/apps/`
   - `<workspace_name>/modules/`
   - `<workspace_name>/packages/`
3. **Configuration Generation**: Creates `<workspace_name>/.fsda/config.yaml` with workspace metadata, Dart/Android defaults, and mandatory bundled packages.
4. **Plan Directory**: Creates `<workspace_name>/.fsda/plans/` for declarative YAML plans.
5. **Operation Report**: Displays a clean, structured terminal summary logging all created directories and files.

### Rerun Behavior

- If the directory `<workspace_name>` already exists, the command halts execution immediately with an error and leaves existing files untouched.

