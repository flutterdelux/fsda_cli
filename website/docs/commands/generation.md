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
- Prints affected paths summary.

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
- Prints affected paths summary.

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
fsda gen-slice `<slice>` -f `<feature>` -m `<module>` -s `<sequence_code>` [-d `<method>`] [-u `<ui_code>`]... [--strict]
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
- If `-u` is provided, automatically runs `gen-ui` for each requested UI code.

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

Optional UI codes can be supplied via -u.

## gen-ui

```bash
fsda gen-ui `<slice>` -f `<feature>` -m `<module>` -u `<ui_code>` [--strict]
```

Generates UI template for a slice and injects exports + ARB entries.

What happens:

- Bakes selected UI template in memory.
- Writes standalone UI files into target feature.
- Updates feature barrel exports from UI manifest.
- Injects ARB keys into module ARB files.
- Runs post-hooks from UI manifest.
- Prints affected paths summary.

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
| `lsh` | List Horizontal |
| `lsv` | List Vertical |
| `pag` | Pagination |
| `pmi` | Popup Menu Item |
| `sec` | Section |
