---
id: releases
title: Releases & Migration Notes
slug: /releases
---

This page summarizes documentation channels and behavior changes that matter for daily CLI usage.

## Version Channels

| Channel | Meaning |
| --- | --- |
| `latest` | Current documentation for ongoing development on main branch. |
| `1.1.0` | Historical snapshot for CLI v1.1.0. |
| `1.0.16` | Historical snapshot for CLI v1.0.16. |

Use the version dropdown in the top-right navbar to switch channels.
The current v2 prerelease (`2.0.0-dev.4`) is documented under `latest`. These notes describe prerelease behavior and may change before stable `2.0.0`.

## Migration Notes

### Upgrading from v1.1.0 to v2.0.0 (prerelease)

> v2.0.0 is a prerelease. Verify these changes against the CLI version you install before updating production workflows.

The command surface was redesigned. Existing v1.1.0 scripts need migration:

| v1.1.0 | v2 prerelease |
| --- | --- |
| `gen-slice` | Use `gen-sequence` for data-to-domain operations, `gen-logic` / `gen-logic-flow` for logic, and `gen-ui*` for UI. |
| `regen-feature` | Removed; no direct replacement. |
| `ui-main`, `ui-dialog`, `ui-form`, `ui-form-dialog`, `ui-lsh`, `ui-lsv`, `ui-pag`, `ui-pmi`, `ui-action`, `ui-sec` | Use the available `gen-ui`, `gen-ui-form`, `gen-ui-lsh`, `gen-ui-lsv`, or `gen-ui-pag` commands. Not every v1 UI variant has a direct v2 equivalent. |
| `gen-ui ... -u <ui_code>` | `gen-ui` is now the standard UI generator and takes `--model`; form/list variants have their own commands. |
| `compose-main`, `compose-pmi`, `compose-sec`, `compose-action`, `compose-form-dialog` | Removed; review whether `compose-r`, `compose-m`, `compose-pag`, or `compose-form` fits the intended output. |
| `compose-*` positional/legacy options | Use `--logic-flow` and `--target`; the command may also require `--ui` or `--logic`. See the current [composition command guide](./commands/compose.md). |
| `reg` | `reg-module`; use `reg-feature` for feature registration. |
| `di`, `rm-reg` | Removed from the current command surface. |
| `list-pckg`, `add-pckg` | `pkg list`, `pkg add`; `pkg get` synchronizes configured packages and `pkg rm` removes them. |
| `configure` (workspace package sync) | `pkg get`. |

Additional migration details:

- Form UI generation now requires `--model` and one or more repeatable `--field "input_type:value_type:field_name[:default]"` options. Update scripts using the v1 `--fields` format.
- Compose commands generate the app-side artifact but do not synchronize module routes. Add or update route wiring in the app separately.
- New modeling and sequence workflows are available through `gen-model` / `rm-model` and `gen-sequence` / `rm-sequence`.
- Maintenance operations are available as `drb`, `l10n`, `rebuild`, `refresh`, and `fix-import`, targeting modules, apps, or both where supported.
- The v2 generated templates still use Flutter's SDK Material imports. Migration to the standalone `material_ui` / `cupertino_ui` packages is not part of this prerelease; check the migration notes for the release that introduces it before changing generated projects.

### Upgrading from v1.0.x to v1.1.0

UI generation now has command-specific entry points:

- `ui-main`
- `ui-dialog`
- `ui-form`
- `ui-form-dialog`
- `ui-lsh`
- `ui-lsv`
- `ui-pag`
- `ui-pmi`
- `ui-action`
- `ui-sec`

Form generation update:

- `ui-form` now requires `--fields` to build dynamic shared field widgets and ARB field labels/hints/invalid messages.
- `ui-form-dialog` provides the same dynamic field generation flow for dialog-based form UX.
- Shared field widgets remain private helpers and are not exported in feature barrel files.
- Param constructor mismatch no longer blocks generation; unresolved fields fall back safely.

Slice/UI generation separation:

- UI generation is intentionally separated from slice generation and should run via dedicated `ui-*` commands.

Action composition mode:

- `compose-action` injects provider/listener/logic execution methods only.
- Button/widget placement remains manual so layout stays fully custom.

Route sync behavior update:

- compose route updates preserve existing base route builder if already customized.

Execution transparency improvements:

- Template pipelines now print explicit dependency/dev-dependency/post-hook plans before execution.
- Affected-path summaries continue to show created/injected/removed/skipped changes for auditability.

### Upgrading from legacy compose surface to v1.0.16+

If your old scripts still call a generic compose command, migrate to explicit compose modes:

- `compose-main`
- `compose-form`
- `compose-form-dialog`
- `compose-dialog`
- `compose-pag`
- `compose-pmi`
- `compose-action`
- `compose-sec`

### Safer reruns and strict mode

Generation and composition flows now prioritize non-destructive behavior:

- Existing files are skipped by default to avoid overwrite.
- Use `--strict` to fail immediately when command safety conditions are not met.

### DI and registration behavior

Operational reruns are designed to be incremental:

- `di` appends only missing registration lines.
- `reg` and compose injectors avoid duplicate snippet insertion.
- Commands report affected paths so changes are easy to audit.

## How to Review Changes Before Commit

1. Run commands for your feature flow.
2. Review affected path summary in terminal output.
3. Verify generated files and injected code in the app/module targets.
4. Run `fsda fix-import` for app/module targets when needed.
