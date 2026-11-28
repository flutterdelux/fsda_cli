---
id: commands-ui
title: UI
---

# UI generation

Use the single `gen-ui` command to generate standard, form, horizontal-list, vertical-list, or pagination UI for an existing feature slice.

```bash
fsda gen-ui -m <module> -f <feature> -s <slice> --model <model> [-t <type>]
```

- `-m`, `--module`: target module.
- `-f`, `--feature`: target feature.
- `-s`, `--slice`: slice name in `snake_case`.
- `--model`: required model name ending in `_entity` or `_param`.
- `-t`, `--type`: UI variant: `standard` (default), `form`, `lsh`, `lsv`, or `pag`.

## Examples

Standard details:

```bash
fsda gen-ui -m catalog -f product -s detail --model product_entity
```

Horizontal list:

```bash
fsda gen-ui -m dashboard -f home -s banner_slider -t lsh --model banner_entity
```

Use `-t lsv` for a vertical list and `-t pag` for pagination. The generated list/pagination variants include item, skeleton, and feedback widgets as appropriate.

## Form variant

Forms require one or more repeatable `--field` options. Each field uses `input_type:value_type:field_name[:default]`.

```bash
fsda gen-ui -m store -f product -s create -t form --model product_create_param \
  --field "text:String:title" \
  --field "number:double:price:0.0" \
  --field "dropdown_enum:TaxType:tax_type" \
  --initial
```

Supported field input types are `text`, `text_area`, `switch`, `password`, `qty`, `number`, `image`, `dropdown`, `dropdown_enum`, and `selector`. Value types can be nullable; custom types used by the form are resolved for generated imports. `--initial` enables an initial-data state for the form.

## Generated behavior

- Creates UI widgets under `modules/<module>/lib/src/features/<feature>/ui/<slice>/`.
- Updates feature barrel exports and module ARB localization entries where the UI variant requires them.
- Requires the target module and feature to exist first.
- Fails if the target UI slice already exists rather than overwriting it.

Run `fsda rebuild -m <module>` after generation when code generation and localization outputs need refreshing. Commands must run from a workspace containing `.fsda/config.yaml`.
