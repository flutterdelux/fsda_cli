---
id: commands-modelling
title: Modelling Commands
---

Modelling commands generate enum and focused domain/data artifacts.

## enum

```bash
fsda enum <enum_name> -f <feature> -m <module> --values <value_1,value_2,...> [--strict] [--hook-disabled]
```

Generates:

- `domain/enums/<enum_name>.dart`
- `data/converters/<enum_name>_converter.dart`
- `ui/shared/extensions/<enum_name>_x.dart`

Also injects enum ARB keys and related feature exports.

Rules:

- `enum_name` must be snake_case.
- `--values` entries must be snake_case.
- Generated Dart enum members are emitted as camelCase (example: `service_charge` -> `serviceCharge`).

## param

```bash
fsda param <name> -f <feature> -m <module> --props "<type:prop_1,type:prop_2,...>" [--strict] [--hook-disabled]
```

Generates Param-only artifact from typed props:

- `domain/params/<name>.dart` (for example `payment_create_param.dart`)

## request

```bash
fsda request <name> -f <feature> -m <module> --props "<type:prop_1,type:prop_2,...>" [--strict] [--hook-disabled]
```

Generates Request-only artifact from typed props:

- `data/requests/<name>.dart` (for example `payment_create_request.dart`)

## param-request

```bash
fsda param-request <prefix> -f <feature> -m <module> --props "<type:prop_1,type:prop_2,...>" [--strict] [--hook-disabled]
```

Generates both Param and Request models simultaneously using shared properties with a single declaration:

- `domain/params/<prefix>_param.dart`
- `data/requests/<prefix>_request.dart`

Rules:

Pass the base prefix in snake_case without suffixes like _param or _request.

## entity

```bash
fsda entity <name> -f <feature> -m <module> --props "<type:prop_1,type:prop_2,...>" [--strict] [--hook-disabled]
```

Generates Entity-only artifact from typed props:

- `domain/entities/<name>.dart` (for example `payment_entity.dart`)


## dto

```bash
fsda dto <name> -f <feature> -m <module> --props "<type:prop_1,type:prop_2,...>" [--strict] [--hook-disabled]
```

Generates DTO-only artifact from typed props:

- `data/dtos/<name>.dart` (for example `payment_dto.dart`)

## entity-dto

```bash
fsda entity-dto <prefix> -f <feature> -m <module> --props "<type:prop_1,type:prop_2,...>" [--strict] [--hook-disabled]
```

Generates both Entity and DTO models simultaneously using shared properties and built-in mappers:

- `domain/entities/<prefix>_entity.dart`
- `data/dtos/<prefix>_dto.dart`

Rules:

Pass the base prefix in snake_case without suffixes like _entity or _dto.Use dto, entity, param, request, param-request, and entity-dto independently based on chaining needs.   

---

Use `dto`, `entity`, `param`, and `request` independently based on chaining needs.

Artifact-name rule:

- Pass the complete generated artifact name in snake_case, including its suffix.
- The name is used unchanged as the output filename stem and is converted to PascalCase for the Dart class name.
- Examples: `payment_dto` generates `PaymentDto`, `payment_entity` generates `PaymentEntity`, and `payment_create_param` generates `PaymentCreateParam`.
- Use matching names to connect related artifacts: `payment_create_param` and `payment_create_request`.

## Typed Props Rules

- Format: `type:name` or `type:name=default`
- `name` must be snake_case
- Nullable type: add `?` (example `DateTime?`)
- Non-nullable fields without default become `required`
- Fields with `=default` are generated with `@Default(...)`
- Generated Dart property identifiers are emitted in camelCase (example: `created_at` -> `createdAt`)
- In zsh, quote `--props` when nullable type (`?`) is present

## Strict and Hook Behavior

- `--strict`: fail when command would skip existing files or cannot inject safely.
- `--hook-disabled`: skip post-hooks and print manual next steps.
