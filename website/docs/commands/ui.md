---
id: commands-ui
title: UI Commands
---

UI commands generate slice UI surfaces and inject ARB/export manifest entries.

## UI Command Family

```bash
fsda ui-main <slice> -f <feature> -m <module> [--strict] [--hook-disabled]
```

```bash
fsda ui-dialog <slice> -f <feature> -m <module> [--strict] [--hook-disabled]
```

```bash
fsda ui-form <slice> -f <feature> -m <module> --fields "<input_type:value_type:field_name,...>" --type <artifact_name> [--initial] [--strict] [--hook-disabled]
```

```bash
fsda ui-form-dialog <slice> -f <feature> -m <module> --fields "<input_type:value_type:field_name,...>" --type <artifact_name> [--initial] [--strict] [--hook-disabled]
```

```bash
fsda ui-lsh <slice> -f <feature> -m <module> --entity <entity> --object <object> [--strict] [--hook-disabled]
```

```bash
fsda ui-lsv <slice> -f <feature> -m <module> --entity <entity> --object <object> [--strict] [--hook-disabled]
```

```bash
fsda ui-pag <slice> -f <feature> -m <module> [--strict] [--hook-disabled]
```

```bash
fsda ui-pmi <slice> -f <feature> -m <module> [--strict] [--hook-disabled]
```

```bash
fsda ui-action <slice> -f <feature> -m <module> [--strict] [--hook-disabled]
```

```bash
fsda ui-sec <slice> -f <feature> -m <module> [--strict] [--hook-disabled]
```

## List UI Notes

`ui-lsh` and `ui-lsv` require both `--entity` and `--object`:

- `--entity` is the full snake_case Entity artifact name, including `_entity` (for example `payment_entity`). The referenced file must exist at `domain/entities/<entity>.dart` in the feature.
- `--object` is the snake_case item variable name used by generated content and item widgets (for example `payment`).

Examples:

```bash
fsda ui-lsh featured -f payment -m billing --entity payment_entity --object payment
fsda ui-lsv payments -f payment -m billing --entity payment_entity --object payment
```

## UI Form Notes

`ui-form` and `ui-form-dialog` now focus on form composition only:

- Shared input widgets are generated via `input-*` commands.
- Field-level ARB keys are generated via `input-*` commands.
- `--fields` supports `input_type:value_type:field_name`.
- `--type <artifact_name>` is required and takes the full snake_case artifact name, including its suffix (for example `wallet_entity`). It defines the form data type and may reference an Entity, DTO, Param, or Request artifact.
- `--initial` is a boolean flag; it takes no value. Use it with `--type <entity_name>` to enable `initialData` hydration for edit/update forms. For example: `--type wallet_entity --initial`.
- CLI identifiers use snake_case (`slice`, `feature`, `module`, `field_name`, and prop names).
- `value_type` follows Dart type naming, and method names use camelCase.

Examples:

- `text:String:title`
- `number:double:rate_percentage`
- `dropdown_enum:ProductStatus:status`
- `selector_list:ProductModifierGroupEntity:modifier_groups`

Supported `input_type` values:

- `text`
- `number`
- `selector`
- `selector_list`
- `text_area`
- `qty`
- `dropdown`
- `dropdown_enum`
- `image`
- `switch`
- `password`

Recommended flow:

1. Generate reusable fields with relevant `input-*` commands.
2. Generate `ui-form` or `ui-form-dialog` using matching typed fields.

Examples:

```bash
fsda ui-form edit -f wallet -m finance --fields "text:String:name" --type wallet_entity --initial
fsda ui-form-dialog create -f wallet -m finance --fields "text:String:name" --type wallet_entity
```

## UI Mapping

| Command | UI mode |
| --- | --- |
| `ui-main` | Main Content |
| `ui-dialog` | Dialog |
| `ui-form` | Form |
| `ui-form-dialog` | Form Dialog |
| `ui-lsh` | List Horizontal |
| `ui-lsv` | List Vertical |
| `ui-pag` | Pagination |
| `ui-pmi` | Popup Menu Item |
| `ui-action` | Action Button |
| `ui-sec` | Section |

## Strict and Hook Behavior

- `--strict`: fail when generation would skip existing files or cannot inject safely.
- `--hook-disabled`: skip post-hooks and print manual next steps.
