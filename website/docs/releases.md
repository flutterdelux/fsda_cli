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
Until a dedicated docs version is cut, v2.0.0 behavior is documented under `latest`.

## Migration Notes

### Upgrading from v1.1.x to v2.0.0

Source of truth for this section is `CHANGELOG.md` entry `2.0.0`.

Breaking changes:

- remove legacy `gen-ui` command from active command surface (use dedicated `ui-*` commands)
- remove legacy `gen-slice` command from active command surface (use dedicated `slice-*` commands)
- `di` command is fixed to module scope: `fsda di <module> -a <app> [--strict]`
- `ui-form` and `ui-form-dialog` with `--fields` no longer generate shared field widgets or field ARB keys

Added:

- dedicated `slice-*` command surface (`slice-m`, `slice-mp`, `slice-mr`, `slice-mrp`, `slice-r`, `slice-rof`, `slice-rp`, `slice-rpag`, `slice-rs`, `slice-rsp`)
- `dto` for typed DTO generation
- `entity` for typed Entity-only generation
- `param` for typed Param-only generation
- `request` for typed Request-only generation
- `input-text`, `input-dropdown`, `input-password` for shared field generation + ARB sync
- `rm-feature` rollback improvements for shared exception/failure/failure-x and ARB keys
- `rm-feature --hook-disabled` parity and improved post-hook diagnostics

Fixes:

- `sequence.yaml` is rendered with generated variables before checkpoint weaving
- generated standalone Dart file normalization to avoid trailing comma/blank-line artifacts
- removal of stale `SequenceCode` fallback path that could trigger unresolved bundle resolver errors

Refactors:

- `build_runner` post-hooks standardized to `dart run build_runner build --delete-conflicting-outputs --force-jit` for Flutter 3/4 compatibility
- v2 docs aligned around explicit `slice-*` and `ui-*` flow with module-scoped `di`

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
