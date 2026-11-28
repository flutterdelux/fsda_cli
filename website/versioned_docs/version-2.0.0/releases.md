---
id: releases
title: Releases & Migration Notes
slug: /releases
---

This page summarizes documentation channels, new workflows in v2.0.0, and migration notes for daily CLI usage.

## Version Channels

| Channel | Meaning |
| --- | --- |
| `2.0.0` (Current) | Stable documentation for CLI v2.0.0. |
| `dev` | Ongoing development on the `main` branch. |
| `1.1.0` | Historical snapshot for CLI v1.1.0. |
| `1.0.16` | Historical snapshot for CLI v1.0.16. |

Use the version dropdown in the top-right navbar to switch channels.

## What's New in v2.0.0

FSDA CLI v2.0.0 introduces **3 Generation Modes** tailored to your development workflow:

1. **Imperative Mode** — Execute consolidated CLI commands directly from your terminal (`fsda gen`, `fsda compose`, `gen-model`, `gen-sequence`, `gen-logic`, `gen-ui`).
2. **Declarative Mode** — Scaffold and apply structured YAML architecture blueprints under `.fsda/plans/` using `fsda plan` and `fsda apply`.
3. **Batch Mode** — Write and edit multiple CLI commands comfortably in `.fsda/run.sh`, then execute them sequentially in a single step via `fsda run`.

## Migration Notes

### Upgrading from v1.1.0 to v2.0.0

The command surface was redesigned and consolidated. Existing v1.1.0 scripts need migration:

| v1.1.0 | v2.0.0 |
| --- | --- |
| `gen-slice` | Use `gen-sequence` for data-to-domain operations, `gen-logic` / `gen-logic-flow` for logic, and `gen-ui` for UI. |
| `regen-feature` | Removed; no direct replacement. |
| `ui-main`, `ui-dialog`, `ui-form`, `ui-form-dialog`, `ui-lsh`, `ui-lsv`, `ui-pag`, `ui-pmi`, `ui-action`, `ui-sec` | Use `gen-ui` with `--type`/`-t` (`standard`, `form`, `lsh`, `lsv`, `pag`). Not every v1 UI variant has a direct v2 equivalent. |
| `gen-ui ... -u <ui_code>` | Use `gen-ui` with `--type`/`-t` and required `--model`; form fields use repeatable `--field`. |
| `compose-main`, `compose-pmi`, `compose-sec`, `compose-action`, `compose-form-dialog` | Replaced by `compose` with `--type` (`r`, `m`, `pag`, `form`) and `--target`. |
| `compose-*` positional/legacy options | Use the unified `compose` command with `--logic-flow` and `--target`; retrieval, pagination, and form also take `--ui`, while form additionally takes `--logic`. See the [compose guide](./commands/compose.md). |
| `reg-module`, `reg-feature` | Use the unified `reg` command: `fsda reg -a <app> -m <module> [-f <feature>]`. |
| `di`, `rm-reg` | Removed from the current command surface. |
| `list-pckg`, `add-pckg` | `pkg list`, `pkg add`; `pkg get` synchronizes configured packages and `pkg rm` removes them. |
| `configure` (workspace package sync) | `pkg get`. `configure -a <app>` now configures an app's infrastructure packages and DI. |
| `gen-app`, `gen-module`, `gen-feature`, `gen-failure` | Use grouped commands: `gen -a <app>`, `gen -m <module>`, `gen -m <module> -f <feature>`, or `gen -m <module> --failure <name:message>`. |
| `rm-feature` | `rm -m <module> -f <feature>`. |

Additional migration details:

- Form UI generation now uses `gen-ui -t form`, requires `--model`, and accepts one or more repeatable `--field "input_type:value_type:field_name[:default]"` options. Update scripts using the v1 `--fields` format.
- Workspace configuration moved from root `fsda.yaml` to `.fsda/config.yaml` (using `dart_sdk` for the Dart constraint); plans are stored below `.fsda/plans/`.
- `plan` scaffolds YAML plan files for app composition, module failures, feature generation, or slice generation. Use `--example` (`-e`) to populate a template with an example.
- `apply <path>` validates and applies one plan file through the same underlying generation services. Applying feature/slice plans auto-creates missing parent module/feature structures and skips existing artifacts where supported; review the operation report and inspect partial changes before reapplying a plan that failed midway.
- App plans compose wrappers only. The app, module/feature registration, and source logic/UI slices must already exist.
- Compose commands generate app-side artifacts but do not synchronize routes. Add or update route wiring in the app separately.
- App/module/feature/failure generators are grouped under `gen`; app/module registration is grouped under `reg`. Use the live CLI help for the exact options of each branch.
- New modeling and sequence workflows are available through `gen-model` / `rm-model` and `gen-sequence` / `rm-sequence`.
- Maintenance operations are available as `drb`, `l10n`, `rebuild`, `refresh`, and `fix-import`, targeting modules, apps, or both where supported.
- `gen -a <app>` now requires app names in `snake_case`; use `--title` for the display name (`--name` is no longer the option).
- Workspace automation scripts can now be executed from the root directory via `fsda run`, which streams `.fsda/run.sh` in real time using `bash` (with automatic Git Bash detection on Windows). See the [run guide](./commands/run.md).


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
