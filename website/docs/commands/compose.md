---
id: commands-compose
title: Compose
---

# Compose a UI wrapper

The unified `compose` command generates an app-side page or widget from existing module logic and UI slices. It does not inject routes; register the feature separately and wire the generated wrapper into the app where needed.

```bash
fsda compose -a <app> -m <module> -f <feature> \
  -t <type> --target <target_name> --logic-flow <slice> \
  [--ui <slice>] [--logic <slice>] [--route]
```

Common options:

- `-a`, `--app`: target app.
- `-m`, `--module`: target module.
- `-f`, `--feature`: target feature.
- `-t`, `--type`: `m` (mutation), `r` (retrieval), `pag` (pagination), or `form`.
- `--target`: generated artifact name. A `_page` suffix places it under `pages/`; other suffixes place it under `widgets/`.
- `--logic-flow`: required flow-driven logic slice.
- `--ui`: required for `r`, `pag`, and `form`.
- `--logic`: required for `form` local form-state logic.
- `--route`: inject route page (if only target is `_page`) to feature base route.

## Examples

Retrieval section:

```bash
fsda compose -a travelkan -m location -f destination \
  -t r --target destination_popular_section \
  --logic-flow popular --ui popular
```

Mutation dialog:

```bash
fsda compose -a portal -m task -f task \
  -t m --target task_delete_dialog --logic-flow delete
```

Form page:

```bash
fsda compose -a portal -m task -f task \
  -t form --target task_create_page \
  --logic-flow create --logic create_form --ui create_form
```

The command inspects generated logic/UI metadata and creates the wrapper only if the destination does not already exist. It requires the module and feature registration structures in the app to exist. Run from a workspace containing `.fsda/config.yaml`.
