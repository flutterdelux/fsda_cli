---
id: declarative
title: Declarative YAML Plans
slug: /declarative
---

# Declarative YAML plans

FSDA CLI supports both its direct command interface and a declarative workflow. Declarative plans describe the same generation operations in YAML and are resolved into the existing generator/service layer when applied.

## Workspace plan layout

A workspace created with `fsda create <workspace>` contains:

```text
.fsda/
  config.yaml
  plans/
    apps/<app>.yaml
    modules/<module>/index.yaml
    modules/<module>/features/<feature>/index.yaml
    modules/<module>/features/<feature>/<slice>.yaml
```

`.fsda/config.yaml` stores workspace settings, including `dart_sdk`, Android SDK values, and active package names. `plan` creates YAML files under `.fsda/plans/`; it does not generate application/module/feature code. `apply` reads a plan file and runs the matching generators.

## Scaffold a plan

Choose a plan scope:

```bash
# Module (including optional module failures)
fsda plan -m <module>

# Feature (feature plus any declared generation sections)
fsda plan -m <module> -f <feature>

# Slice (feature and one slice plus generation sections)
fsda plan -m <module> -f <feature> -s <slice>

# App composition plan
fsda plan -a <app>
```

Add `--example` (`-e`) to generate a CRUD-oriented example plan. The command refuses to overwrite an existing plan file.

## Apply a plan

Pass a path relative to the workspace root or an absolute path:

```bash
fsda apply .fsda/plans/modules/location/features/destination/popular.yaml
```

The YAML root determines its plan scope. `apply` validates/parses the file before execution and reports affected paths. Feature/slice plans ensure their parent module and feature exist, then process generation sections in dependency order: data sources, enums, models, sequences, logic, logic flows, inputs, and UI. Existing artifacts are skipped for several sections; sequence injection can still fail if its target methods or use case already exist, so reruns should be reviewed rather than assumed to be fully idempotent.

An app plan only composes the listed app-side wrappers; the app, module registration, feature registration, and source logic/UI slices must already exist. It does not create/register an app or mutate routes.

## Plan scopes and schema

### Module plan

The root `module` selects the module. Optional `failure` entries accept either `name`/`message` maps or the supported `name:message` shorthand:

```yaml
module: location
failure:
  - name: destination_not_found
    message: Destination not found.
  - "destination_load_failed:Unable to load destinations."
```

This scope creates the module if missing and then injects the listed failure entries into the module's existing failure/localization artifacts.

### Feature plan

A feature plan requires both `module` and `feature`. Each generation section is optional:

```yaml
module: location
feature: destination

ds:
  remote:
    base-path: "/destinations"

enum:
  - name: destination_status
    values: draft, published, archived
    lower: true

model:
  - name: destination_entity
    with-dto: true
    l10n: true
    prop:
      - "int:id"
      - "String:name"
      - "DateTime:created_at::UtcDateTimeConverter"

sequence:
  - uc: destination_list_use_case
    act: get
    method: get_destination_list
    ds: remote
    flow: async
    list: true
    model:
      - destination_dto
      - destination_entity
      - destination_list_response

logic:
  - slice: create_form
    control: cubit
    prop:
      - "String?:name"
      - "String?:invalid_message"

logic-flow:
  - slice: list
    type: r
    uc: destination_list_use_case
    control: cubit

input:
  - type: text
    field: name
  - type: number
    field: rating
    data-type: double
  - type: text_area
    field: description
    min: 2
    max: 5

ui:
  - slice: list
    type: lsv
    model: destination_entity
  - slice: create_form
    type: form
    model: destination_create_param
    field:
      - "text:String:name"
      - "number:double:rating"
```

Supported sections and keys:

- `ds.remote.base-path` generates a remote data source; `ds.local.cache-key` generates a local data source. Both may be declared.
- `enum[]`: `name`, comma-separated `values`, optional boolean `lower`.
- `model[]`: `name` with `_entity`, `_dto`, `_param`, `_request`, or `_response` suffix; repeatable `prop[]`; optional `with-dto`, `with-request`, and `l10n` flags where valid.
- `sequence[]`: required `uc`, `act`, `method`, and `ds`; optional `flow` (`async`, `sync`, `stream`), `list`, and `model[]`.
- `logic[]`: required `slice` and non-empty `prop[]`; optional `control` (`cubit`, `provider`, `riverpod`, `getx`; defaults to Cubit).
- `logic-flow[]`: required `slice`, `type` (`m`, `r`, `pag`), and `uc`; optional `control` (defaults to Cubit).
- `input[]`: required `type` and `field`. Types: `text`, `text_area`, `switch`, `password`, `qty`, `number`, `image`, `dropdown`, `dropdown_enum`, `selector`. Use `data-type` for typed input variants, `min`/`max` for text areas, and `list: true` for a selector list.
- `ui[]`: required `slice` and `model`; optional `type` (`standard`, `form`, `lsh`, `lsv`, `pag`, default `standard`), `field[]` for forms, and `initial` for initial-data forms.

Properties can be concise strings such as `"String:title"` or maps:

```yaml
prop:
  - type: DateTime
    name: created_at
    converter: UtcDateTimeConverter
```

A slice plan has the same generation sections as a feature plan, plus a root `slice` name. Sections in a slice plan can include prerequisites that belong to the parent feature; the applier creates the module/feature first and applies each declared section.

### App plan

An app plan has root `app` plus optional `compose[]` entries:

```yaml
app: travelkan
compose:
  - module: location
    feature: destination
    type: r
    target: destination_popular_section
    logic-flow: popular
    ui: popular
  - module: location
    feature: destination
    type: m
    target: destination_delete_dialog
    logic-flow: delete
```

Compose `type` accepts `r`, `m`, `pag`, and `form`. Retrieval/pagination require `ui`; form also requires `logic`. Targets ending in `_page` go to the app feature's `pages/` directory; other targets go under `widgets/`.

## Validation and safe application

- YAML syntax and section types are validated before the selected plan is applied. Errors include the section and item number where available.
- Plan scaffolding does not overwrite existing plan files.
- Feature/slice plans skip existing data-source implementation, enum/model files, logic slices, input widgets, and UI slices where the applier checks for those artifacts. Sequences are delegated to the sequence service and enforce their own conflict checks.
- App composition skips a target file that already exists.
- Applying a plan is not a transactional rollback. If a later operation fails, inspect the operation report and files already written before reapplying.

See the [command reference](./commands/index.md) and [release migration notes](./releases.md) for the direct CLI surface and version-specific changes.
