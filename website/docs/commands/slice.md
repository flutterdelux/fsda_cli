---
id: commands-slice
title: Slice Commands
---

Slice commands generate sequence-specific feature scaffolding while reusing existing feature structure.

`gen-slice` is no longer part of the active surface. Use the dedicated `slice-*` commands below.

## Shared Usage Pattern

```bash
fsda slice-<mode> <slice> -f <feature> -m <module> -d <method> [...mode options] [--hook-disabled]
```

Shared flags:

- `-f, --feature`: target feature name
- `-m, --module`: target module name
- `-d, --method`: datasource/repository method name
- `--hook-disabled`: skip post-hook execution and print manual next steps

Common behavior:

- Generates slice artifacts under existing feature directories.
- Injects managed snippet checkpoints (datasource, repository, usecase, logic, exports) idempotently.
- Skips existing standalone files by default.

## Mutation

```bash
fsda slice-m <slice> -f <feature> -m <module> -d <method> [--hook-disabled]
```

Generates mutation slice without Param.

## Mutation + Param

```bash
fsda slice-mp <slice> -f <feature> -m <module> -d <method> [--param <name>] [--request <name>] [--param-request <prefix>] [--hook-disabled]
```

Generates mutation + Param/Request slice by reusing existing Param/Request artifacts.

## Mutation + Return

```bash
fsda slice-mr <slice> -f <feature> -m <module> -d <method> [--list] [--entity <name>] [--dto <name>] [--entity-dto <prefix>] [--hook-disabled]
```

Generates mutation + return-model slice by reusing existing DTO/Entity artifacts.

## Mutation + Return + Param

```bash
fsda slice-mrp <slice> -f <feature> -m <module> -d <method> [--list] [--entity <name>] [--dto <name>] [--entity-dto <prefix>] [--param <name>] [--request <name>] [--param-request <prefix>] [--hook-disabled]
```

Generates mutation + return-model + Param/Request slice.

## Retrieval

```bash
fsda slice-r <slice> -f <feature> -m <module> -d <method> [--list] [--entity <name>] [--dto <name>] [--entity-dto <prefix>] [--hook-disabled]
```

Generates retrieval slice.

## Retrieval + Offline-First

```bash
fsda slice-rof <slice> -f <feature> -m <module> -d <method> [--list] [--entity <name>] [--dto <name>] [--entity-dto <prefix>] [--hook-disabled]
```

Generates retrieval + offline-first slice.

## Retrieval + Param

```bash
fsda slice-rp <slice> -f <feature> -m <module> -d <method> [--list] [--entity <name>] [--dto <name>] [--entity-dto <prefix>] [--param <name>] [--request <name>] [--param-request <prefix>] [--hook-disabled]
```

Generates retrieval + Param/Request slice.

## Retrieval + Pagination

```bash
fsda slice-rpag <slice> -f <feature> -m <module> -d <method> [--entity <name>] [--dto <name>] [--entity-dto <prefix>] [--param <name>] [--request <name>] [--param-request <prefix>] [--hook-disabled]
```

Generates retrieval + pagination slice.

Pagination rule:

- Param source referenced by `--param` must include `int page` and `int page_size`.

## Retrieval + Stream

```bash
fsda slice-rs <slice> -f <feature> -m <module> -d <method> [--list] [--entity <name>] [--dto <name>] [--entity-dto <prefix>] [--hook-disabled]
```

Generates retrieval + stream slice.

## Retrieval + Stream + Param

```bash
fsda slice-rsp <slice> -f <feature> -m <module> -d <method> [--list] [--entity <name>] [--dto <name>] [--entity-dto <prefix>] [--param <name>] [--request <name>] [--param-request <prefix>] [--hook-disabled]
```

Generates retrieval + stream + Param/Request slice.

## Artifact Name Rules

- An Entity/DTO pair is required in: `slice-mr`, `slice-mrp`, `slice-r`, `slice-rof`, `slice-rp`, `slice-rpag`, `slice-rs`, `slice-rsp`. Supply both `--entity` and `--dto`, or use `--entity-dto <prefix>`.
- A Param/Request pair is required in: `slice-mp`, `slice-mrp`, `slice-rp`, `slice-rpag`, `slice-rsp`. Supply both `--param` and `--request`, or use `--param-request <prefix>`.
- Explicit values are snake_case filename stems and may use any suffix (for example `--dto payment_view --entity payment_record`).
- Pass the full generated filenames' stems, for example `--dto payment_dto --entity payment_entity` for conventionally named files.
- DTO and Entity artifact names may differ. The generated model type follows the DTO name, while generated Entity references use the provided Entity name.
- Param and Request explicit names are used as exact filename stems; they do not need to end in `_param` or `_request`.
- Shortcut prefixes are snake_case base names. `--entity-dto payment` expands to `payment_entity` and `payment_dto`; `--param-request payment_create` expands to `payment_create_param` and `payment_create_request`.
- Specific options take precedence independently. For example, `--param-request payment_create --param payment_upsert` resolves to `payment_upsert` and `payment_create_request`. The corresponding `--entity`/`--dto` options behave the same with `--entity-dto`.
- Shortcuts only derive names; all resolved artifacts must already exist. Specific names remain available when the paired artifacts have different prefixes or naming rules evolve.
- Run modelling commands first to prepare artifact files: `fsda dto`, `fsda entity`, `fsda param`, and `fsda request`.

Examples:

```bash
# concise: same prefix for Entity/DTO and Param/Request
fsda slice-mrp update -f payment -m finance -d updatePayment --entity-dto payment --param-request payment_update

# explicit names override only the corresponding shortcut-derived name
fsda slice-rp list -f payment -m finance -d listPayments --entity-dto payment --dto payment_summary_dto --param-request payment_filter
```

Notes:

- `--hook-disabled` skips post-hook execution and prints manual next-step commands.
- Slice generation updates checkpoints and feature barrel exports idempotently.
