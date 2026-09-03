---
id: commands-workspace
title: Workspace Commands
---

## create

```bash
fsda create <workspace_name>
```

Creates a new FSDA workspace root.

## configure

```bash
fsda configure
```

Synchronizes workspace/packages from fsda.yaml package list.

## configure-app

```bash
fsda configure-app <app>
```

Synchronizes app package dependencies against workspace/packages.

## list-pckg

```bash
fsda list-pckg
```

Lists package templates that can be added.

## add-pckg

```bash
fsda add-pckg <name>
```

Adds a package template to workspace/packages and updates workspace config.
