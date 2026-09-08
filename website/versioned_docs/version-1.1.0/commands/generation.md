---
id: commands-generation
title: Generation Commands
---

These commands generate app/module/feature/slice/UI baselines and weave code into FSDA checkpoints.

## gen-app

```bash
fsda gen-app `<app>`
```

Generates a Flutter app in `apps/<app>`.

What happens:

- Runs `flutter create` for `apps/<app>`.
- Removes default `test` directory from generated app template.
- Applies FSDA app brick overlay.
- Adds app dependencies/dev dependencies.
- Runs configured post-hooks.
- Prints dependency/dev-dependency/post-hook execution plan before pipeline starts.
- Prints concise affected paths (important app roots/config/lib targets), not every platform/template file.

Rerun behavior:

- If `apps/<app>` already exists, command stops and does not overwrite.

## gen-module

```bash
fsda gen-module `<module>`
```

Generates module baseline in `modules/<module>`.

What happens:

- Bakes module brick into `modules/<module>`.
- Adds module dependencies/dev dependencies.
- Runs module post-hooks (`flutter gen-l10n` and `build_runner`).
- Prints dependency/dev-dependency/post-hook execution plan before pipeline starts.
- Prints concise affected paths (important module roots/config/lib targets), not every generated/internal artifact.

Rerun behavior:

- If `modules/<module>` already exists, command stops and does not overwrite.

## gen-feature

```bash
fsda gen-feature `<feature>` -m `<module>` [--ds `<datasource_mode>`]
```

Generates feature baseline in `modules/<module>/lib/src/features/<feature>`.

What happens:

- Bakes feature brick into target feature directory.
- Applies datasource mode (`both`, `remote`, `local`) by shaping datasource/repository scaffolds.
- Injects baseline error contracts and ARB boundary snippets.
- Updates module barrel export in `modules/<module>/lib/<module>.dart`.
- Runs `flutter gen-l10n` when ARB files are touched.
- Prints affected paths summary.

Rerun behavior:

- If feature folder already exists, command stops and does not overwrite.

Supported datasource modes:

- both
- remote
- local

## regen-feature

```bash
fsda regen-feature `<feature>` -m `<module>` [--ds `<datasource_mode>`]
```

Regenerates only missing baseline files for an existing feature.

What happens:

- Rebuilds feature baseline in temporary directory.
- Copies only files missing in existing feature directory.
- Keeps existing files unchanged.
- Refreshes feature barrel data exports when required.
- Prints added vs kept summary through affected paths.

Rerun behavior:

- Existing files are preserved.
- Missing files are restored.

## gen-slice

```bash
fsda gen-slice `<slice>` -f `<feature>` -m `<module>` -s `<sequence_code>` [-d `<method>`] [--strict]
```

Generates sequence slice files and weaves slice code into datasource/repository checkpoints.

What happens:

- Bakes sequence template in memory from selected sequence code.
- Writes standalone generated files under target feature.
- Injects imports and code snippets to target files in:
	- `data/datasources/*`
	- `domain/repositories/*`
	- `data/repositories/*`
- Updates feature barrel exports based on template manifest.
- Runs post-hooks from sequence manifest.

Rerun behavior:

- Existing standalone files are skipped by default.
- Duplicate injected code/imports are not re-added.

Strict mode behavior:

- Fails if any generated standalone file already exists.
- Fails if required injection checkpoint is missing and fallback injection would be needed.

Supported sequence codes:

| Code | Meaning |
| --- | --- |
| `M` | Mutation |
| `Mp` | Mutation + Param |
| `Mr` | Mutation + Return |
| `Mrp` | Mutation + Return + Param |
| `R` | Retrieval |
| `Rp` | Retrieval + Param |
| `Rpag` | Retrieval + Pagination |
| `Rs` | Retrieval + Stream |
| `Rsp` | Retrieval + Stream + Param |
| `Rof` | Retrieval + Offline First |

UI generation is intentionally separated from `gen-slice`.
Use dedicated `ui-*` commands after slice generation.

## gen-enum

```bash
fsda gen-enum <enum_name> -f <feature> -m <module> --values <value_1,value_2,...> [--strict]
```

Generates enum artifacts for a feature and injects related ARB/export entries.

Naming expectations:

- `enum_name` must be snake_case.
- `--values` entries must be snake_case.

What happens:

- Bakes enum brick in memory and writes files under target feature:
	- `domain/enums/<enum_name>.dart`
	- `data/converters/<enum_name>_converter.dart`
	- `ui/shared/extensions/<enum_name>_x.dart`
- Injects feature barrel exports:
	- `export 'domain/enums/<enum_name>.dart';`
	- `export 'ui/shared/extensions/<enum_name>_x.dart';`
- Injects ARB keys into module l10n files based on enum values.
	- Key pattern: `<enumCamel>Label`, `<enumCamel><ValuePascal>`
- Runs `flutter gen-l10n` when ARB files are updated.

Rerun behavior:

- Existing generated enum files are skipped by default.
- Duplicate export/ARB keys are not re-added.

Strict mode behavior:

- Fails if generated enum files already exist.

## dedicated ui-* commands (recommended)

```bash
fsda ui-main `<slice>` -f `<feature>` -m `<module>` [--strict]
fsda ui-dialog `<slice>` -f `<feature>` -m `<module>` [--strict]
fsda ui-form `<slice>` -f `<feature>` -m `<module>` --fields `<field_1,field_2,...>` [--strict]
fsda ui-form-dialog `<slice>` -f `<feature>` -m `<module>` --fields `<field_1,field_2,...>` [--strict]
fsda ui-lsh `<slice>` -f `<feature>` -m `<module>` [--strict]
fsda ui-lsv `<slice>` -f `<feature>` -m `<module>` [--strict]
fsda ui-pag `<slice>` -f `<feature>` -m `<module>` [--strict]
fsda ui-pmi `<slice>` -f `<feature>` -m `<module>` [--strict]
fsda ui-action `<slice>` -f `<feature>` -m `<module>` [--strict]
fsda ui-sec `<slice>` -f `<feature>` -m `<module>` [--strict]
```

Generates UI template for a slice and injects exports + ARB entries.

What happens:

- Bakes selected UI template in memory.
- Writes standalone UI files into target feature.
- Updates feature barrel exports from UI manifest.
- Injects ARB keys into module ARB files.
- Runs post-hooks from UI manifest.
- Prints affected paths summary with command-specific operation labels.

Rerun behavior:

- Existing standalone UI files are skipped by default.
- Duplicate export/ARB injections are avoided.

Strict mode behavior:

- Fails if generated standalone UI files already exist.

`ui-form` notes:

- `--fields` is required.
- Generates shared field widgets per field name with file pattern `ui/shared/widgets/<feature>_<field>_field.dart`.
- Injects matching field ARB keys (`Label`, `Hint`, `InvalidEmpty`).
- Shared field widgets remain private helpers and are not exported from feature barrel.
- Param constructor mismatch no longer blocks generation; unresolved fields are mapped with safe fallback values.

`ui-form-dialog` notes:

- Same dynamic `--fields` behavior as `ui-form`.
- Generates dialog-oriented widget entry (`..._dialog.dart`) for manual page integration.

UI command mapping:

| Command | Code | Meaning |
| --- | --- | --- |
| `ui-main` | `main` | Main Content |
| `ui-dialog` | `dialog` | Alert Dialog |
| `ui-form` | `form` | Form |
| `ui-form-dialog` | `form_dialog` | Form Dialog |
| `ui-lsh` | `lsh` | List Horizontal |
| `ui-lsv` | `lsv` | List Vertical |
| `ui-pag` | `pag` | Pagination |
| `ui-pmi` | `pmi` | Popup Menu Item |
| `ui-action` | `action` | Action Button |
| `ui-sec` | `sec` | Section |

## gen-ui (legacy)

```bash
fsda gen-ui `<slice>` -f `<feature>` -m `<module>` -u `<ui_code>` [--strict]
```

Legacy wrapper for UI generation. Prefer command-specific ui-* commands.

What happens:

- Bakes selected UI template in memory.
- Writes standalone UI files into target feature.
- Updates feature barrel exports from UI manifest.
- Injects ARB keys into module ARB files.
- Runs post-hooks from UI manifest.
- Prints migration hint and affected paths summary.

Rerun behavior:

- Existing standalone UI files are skipped by default.
- Duplicate export/ARB injections are avoided.

Strict mode behavior:

- Fails if generated standalone UI files already exist.

Supported UI codes:

| Code | Meaning |
| --- | --- |
| `main` | Main Content |
| `dialog` | Alert Dialog |
| `form` | Form |
| `form_dialog` | Form Dialog |
| `lsh` | List Horizontal |
| `lsv` | List Vertical |
| `pag` | Pagination |
| `pmi` | Popup Menu Item |
| `action` | Action Button |
| `sec` | Section |
