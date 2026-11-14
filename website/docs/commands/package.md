---
id: commands-package
title: Package
---

These commands manage package templates and dependencies within an FSDA workspace under the `fsda pkg` namespace.

## list

```bash
fsda pkg list

```

Lists all available package templates bundled within FSDA CLI.

### What Happens

* Scans and prints a clean, sorted terminal list of all built-in package templates available in the CLI bundle.
* Displays a helpful guidance tip on how to add or configure packages in your `fsda.yaml` file.

### Rerun Behavior

* Since this is a read-only informational command, it does not modify any files or directories. It is completely safe to rerun at any time.

## get

```bash
fsda pkg get
```

Synchronizes workspace packages based on active declarations in `fsda.yaml`.

### Workspace Guard

* Must be executed inside an FSDA workspace root directory where `fsda.yaml` is located. If executed outside, the command will abort immediately with an error.

### What Happens

1. **Reads Workspace Configuration**: Parses the active packages declared under the `packages` list in `fsda.yaml`.
2. **Package Synchronization**:
* **Added**: Copies new active packages from the CLI template bundle into `packages/` if they do not exist yet.
* **Removed**: Deletes packages from `packages/` if they are commented out or inactive in `fsda.yaml`.
* **Retained**: Keeps existing active packages untouched.


3. **Synchronization Summary Report**: Prints a categorized terminal report logging `Added`, `Removed`, and `Retained` packages (or `- no package change detected` if no changes or active packages are present).

### Rerun Behavior

* Completely safe and idempotent. Running `fsda pkg get` multiple times without changing `fsda.yaml` will retain existing packages and report no package changes, keeping your workspace consistently synchronized.

## add

```bash
fsda pkg add <pkg_1> <pkg_2> ...
```

Adds one or more package templates to `fsda.yaml` and automatically synchronizes the workspace.

### Workspace Guard

* Must be executed inside an FSDA workspace root directory where `fsda.yaml` is located.

### What Happens

1. **Validates Packages**: Checks if the specified package names exist in the CLI template bundle.
2. **Updates Configuration**: Safely appends the requested packages to the end of the `packages` list in `fsda.yaml`.
3. **Automatic Synchronization**: Immediately triggers workspace package synchronization (equivalent to running `fsda pkg get`).

### Usage Example

```bash
fsda pkg add infra_dio infra_flutter_secure_storage
```

## rm

```bash
fsda pkg rm <pkg_1> <pkg_2> ...
```

Removes one or more package templates from `fsda.yaml` and automatically synchronizes the workspace.

### Workspace Guard

* Must be executed inside an FSDA workspace root directory where `fsda.yaml` is located.

### What Happens

1. **Updates Configuration**: Safely removes the specified packages from the `packages` list in `fsda.yaml`.
2. **Automatic Synchronization**: Immediately triggers workspace package synchronization, safely deleting removed packages from the local `packages/` directory.

### Usage Example

```bash
fsda pkg rm infra_hive
```