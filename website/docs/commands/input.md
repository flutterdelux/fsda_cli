---
id: commands-input
title: Input Commands
---

Input commands generate reusable shared field widgets under feature `ui/shared/widgets` and update ARB keys.

Each `input-*` command now targets exactly one field per run.

Field argument format:

- Preferred: positional `<field>`
- Alternative: `--field <field>`

## input-text

```bash
fsda input-text <field> -f <feature> -m <module> [--strict] [--hook-disabled]
```

String text field generation.

## input-text-area

```bash
fsda input-text-area <field> -f <feature> -m <module> [--min <min_lines>] [--max <max_lines>] [--strict] [--hook-disabled]
```

Multiline text field generation (String-only by design) with configurable min/max lines.

## input-number

```bash
fsda input-number <field> -f <feature> -m <module> [--type <numeric_type>] [--strict] [--hook-disabled]
```

Numeric text field generation.

Rules:

- Supported `--type`: `int`, `double`, `num`, `BigInt`
- Default type: `double`

## input-qty

```bash
fsda input-qty <field> -f <feature> -m <module> [--strict] [--hook-disabled]
```

Quantity field generation with increment/decrement controls.

## input-dropdown

```bash
fsda input-dropdown <field> -f <feature> -m <module> --type <value_type> [--strict] [--hook-disabled]
```

Typed dropdown field generation.

Notes:

- `--type` accepts Dart type (for example `String`, `ProductCategoryEntity`) or snake_case alias (for example `product_category_entity`).
- Snake_case aliases must be the complete generated artifact name, including `_entity` or `_dto` where applicable.
- Generated widget exposes optional `itemLabelBuilder` callback and falls back to `item.toString()`.

## input-dropdown-enum

```bash
fsda input-dropdown-enum <field> -f <feature> -m <module> --type <enum_type> [--strict] [--hook-disabled]
```

Enum-backed dropdown generation with localization extension support.

Notes:

- `--type` must be the complete snake_case enum name (for example `product_status`), matching `domain/enums/product_status.dart`.
- Generated widget builds entries from `<EnumType>.values`.

## input-selector

```bash
fsda input-selector <field> -f <feature> -m <module> --type <entity_type> [--strict] [--hook-disabled]
```

Selector field wrapper for entity-style selection flows.

Generated selector widget now uses `onSelect(currentSelected)` callback contract and can emit selected value updates via `onSelected`.

Notes:

- `--type` must be the complete snake_case Entity name ending in `_entity` (for example `product_category_entity`).
- Command expects the exact generated entity file at `domain/entities/<entity_type>.dart`.

## input-selector-list

```bash
fsda input-selector-list <field> -f <feature> -m <module> --type <entity_type> [--strict] [--hook-disabled]
```

Selector-list field wrapper for multi-entity selection flows.

Notes:

- `--type` must be the complete snake_case Entity name ending in `_entity` (for example `product_category_entity`).
- Command expects the exact generated entity file at `domain/entities/<entity_type>.dart`.

## input-image

```bash
fsda input-image <field> -f <feature> -m <module> --type <value_type> [--strict] [--hook-disabled]
```

Image selector/preview field generation.

Generated image selector widget now uses `onSelect(currentSelected)` callback contract and can emit selected value updates via `onSelected`.

Notes:

- `--type` is required.
- Use the complete snake_case value name: `network_file` or Entity name ending in `_entity` (`product_image_entity`).
- For Entity values, command expects the exact generated file at `domain/entities/<value_type>.dart`.

## input-switch

```bash
fsda input-switch <field> -f <feature> -m <module> [--strict] [--hook-disabled]
```

Readonly switch field generation.

## input-password

```bash
fsda input-password <field> -f <feature> -m <module> [--strict] [--hook-disabled]
```

Password field generation with visibility toggle.

## Shared Behavior

- All input commands generate shared widget files:
  - `ui/shared/widgets/<feature>_<field>_field.dart`
- ARB keys are injected by field type profile (label/hint/invalid or equivalent toggle keys).
- `ui-form` and `ui-form-dialog` no longer require `resolveEntries` callbacks for dropdown and dropdown-enum fields.
- `ui-form` and `ui-form-dialog` auto-import required value types (Entity/Dto/Enum/NetworkFile) based on `--fields` types.
- `--strict` fails on unsafe overwrite/injection states.
- `--hook-disabled` skips post-hooks and prints manual next steps.
