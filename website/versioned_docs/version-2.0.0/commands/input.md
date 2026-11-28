---
id: commands-input
title: Input
---

# Generate an input widget

Use `gen-input` for all input widget types:

```bash
fsda gen-input -m <module> -f <feature> -t <type> --field <field> \
  [--data-type <type>] [--min <int>] [--max <int>] [--list]
```

Required options:

- `-m`, `--module`: target module.
- `-f`, `--feature`: target feature.
- `-t`, `--type`: input widget type.
- `--field`: field name in `snake_case`.

Supported types: `text`, `text_area`, `switch`, `password`, `qty`, `number`, `image`, `dropdown`, `dropdown_enum`, and `selector`.

## Type-specific options

- `--data-type` is required for `dropdown`, `dropdown_enum`, and `selector`; optional for `number` (defaults to `int`) and `image` (defaults to `NetworkFile`).
- `--min` and `--max` set text-area line limits (both default to 3).
- `--list` creates a list/multi-select widget for `selector`.

Examples:

```bash
fsda gen-input -m profile -f account -t text --field username
fsda gen-input -m catalog -f product -t number --field price --data-type double
fsda gen-input -m order -f shipping -t text_area --field address --min 2 --max 4
fsda gen-input -m catalog -f product -t dropdown --field category --data-type Category
fsda gen-input -m blog -f article -t selector --field tags --data-type Tag --list
```

The command validates the field and type, generates the widget under the feature UI directory, resolves imports for custom types, and adds associated localization entries. It refuses to overwrite an existing widget. Run it from a workspace containing `.fsda/config.yaml`.
