---
id: commands-run
title: Run
---

This command executes custom workspace automation scripts defined in `.fsda/run.sh` from your FSDA workspace root directory.

## Workspace Guard

Must be executed inside an FSDA workspace root directory where `.fsda/config.yaml` is present. If executed outside, the command will abort immediately with an error.

## run

```bash
fsda run
```

Executes the shell script located at `.fsda/run.sh` using `bash`.

### What Happens
1. **Validates Arguments**: Ensures no extra positional arguments are supplied (`fsda run` takes no additional arguments).
2. **Script Verification**: Verifies that `.fsda/run.sh` physically exists inside the workspace root directory.
3. **Executes Script**: Runs the script from the workspace root directory:

   ```bash
   bash .fsda/run.sh
   ```

## Example `.fsda/run.sh`

You can chain multiple `fsda` or Flutter/Dart commands inside `.fsda/run.sh` to automate repetitive workspace workflows:

```bash
#!/bin/bash
set -e

fsda pkg get
fsda rebuild -m auth -a main_app
fsda fix-import -m auth -a main_app
```

> **Tip**: Including `set -e` at the top of your `.fsda/run.sh` ensures the script stops immediately if any command fails, allowing `fsda run` to catch and report the error properly.

## Behavior & Error Handling

- **Missing Script**: If `.fsda/run.sh` does not exist, the command aborts immediately with an error message indicating the missing path.
- **Working Directory**: The script always runs with the FSDA workspace root as its current working directory, so relative paths inside `.fsda/run.sh` resolve from the root.
- **Non-Zero Exit Code**: If `bash` exits with a non-zero status code, `fsda run` halts and surfaces the `stderr` output in the terminal.
