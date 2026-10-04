---
id: commands-composition
title: Composition Commands
---

Composition commands integrate generated feature slices into app pages and optionally into routes.

Implementation note:

- Public command surface has 8 compose commands.
- Internally they are routed into 3 composition engines:
    - main/form/form-dialog/dialog -> main service
    - pag -> pagination service
    - pmi/action/sec -> inject service

## Shared Preconditions

- Run from workspace root.
- Target module wrapper in app must already exist (`fsda reg <module> -a <app>`).
- Target feature and slice logic must exist.
- `--page` must use snake_case for the exact target page name (e.g., `wallet_detail_page`).
- Module route file `apps/<app>/lib/modules/<module>/<module>_route.dart` must exist only when `--route` is used.

## compose-main

```bash
fsda compose-main <slice> -f <feature> -m <module> -a <app> -p <target_page> [--route] [--strict]

```

Creates a new view-driven page composition and optionally syncs route wiring.

What happens:

* Requires a view class under `modules/<module>/lib/src/features/<feature>/ui/<slice>/views` (the view widget is not required to be a `Scaffold`).
* Generates page file: `apps/<app>/lib/modules/<module>/features/<feature>/pages/<target_page>.dart`.
* Injects provider/listener wiring based on detected logic class.
* If `--route` is provided, updates module route file with child route + navigation helper while preserving existing base route builder.
* Prints affected paths summary.

Rerun behavior:

* If target page already exists, page generation is skipped.
* Route update runs idempotently when `--route` is used.

Strict mode behavior:

* Fails when target page already exists.

## compose-form

```bash
fsda compose-form <slice> -f <feature> -m <module> -a <app> -p <target_page> [--route] [--strict]

```

Creates a form-style page composition and optionally syncs route wiring.

What happens:

* Same pipeline as `compose-main`, but generated page scaffold is form-oriented.
* If `--route` is provided, updates module route file with child route + navigation helper while preserving existing base route builder.

Rerun behavior:

* If target page already exists, page generation is skipped.
* Route update runs idempotently when `--route` is used.

Strict mode behavior:

* Fails when target page already exists.

## compose-form-dialog

```bash
fsda compose-form-dialog <slice> -f <feature> -m <module> -a <app> -p <target_page> [--route] [--strict]

```

Creates a dialog-based form composition for showDialog() usage, with optional route wiring.

What happens:

* Uses generated dialog widget (`..._dialog.dart`) as primary page surface.
* Reuses form cubit/form widget flow from feature slice logic.
* Generates the target page scaffold.
* If `--route` is provided, also updates module route file with child route + navigation helper.

Rerun behavior:

* If target page already exists, page generation is skipped.
* Route update runs only when `--route` is used.

Strict mode behavior:

* Fails when target page already exists.

## compose-dialog

```bash
fsda compose-dialog <slice> -f <feature> -m <module> -a <app> -p <target_page> [--route] [--strict]

```

Creates a dialog-first action composition for showDialog() usage, with optional route wiring.

What happens:

* Uses generated dialog widget (`..._dialog.dart`) as primary page surface.
* Injects provider/listener wiring and an execution helper method based on detected action logic.
* Supports required-argument logic methods by generating TODO fallback in helper when argument mapping must be provided manually.
* Generates the target page scaffold.
* If `--route` is provided, also updates module route file with child route + navigation helper.

Rerun behavior:

* If target page already exists, page generation is skipped.
* Route update runs only when `--route` is used.

Strict mode behavior:

* Fails when target page already exists.

## compose-pag

```bash
fsda compose-pag <slice> -f <feature> -m <module> -a <app> -p <target_page> [--route] [--strict]

```

Creates a pagination page composition flow.

What happens:

* Requires view widget and pagination content widget from the slice UI.
* Generates page file in app module feature pages directory.
* Builds pagination wiring (refresh/loadMore behavior based on detected logic methods/state shape).
* If `--route` is provided, updates module route file with child route + navigation helper while preserving existing base route builder.

Rerun behavior:

* If target page already exists, page generation is skipped.
* Route update runs idempotently when `--route` is used.

Strict mode behavior:

* Fails when target page already exists.

## compose-pmi

```bash
fsda compose-pmi <slice> -f <feature> -m <module> -a <app> -p <target_page> [--route] [--strict]

```

Injects popup menu action flow into a target page.

What happens:

* Looks for popup menu item widget from slice UI widgets.
* Injects imports, provider/listener wiring, execution method, and popup action handler into target page.
* If target page does not exist:
* non-strict mode creates a minimal scaffold page first, then injects
* strict mode fails


* If `--route` is provided, updates module route file with child route + navigation helper while preserving existing base route builder.

Rerun behavior:

* Injection is upsert-style and avoids duplicate snippets.

Strict mode behavior:

* Fails if target page is missing and scaffold creation would be required.

## compose-action

```bash
fsda compose-action <slice> -f <feature> -m <module> -a <app> -p <target_page> [--route] [--strict]

```

Injects action logic flow into a target page without injecting button placement.

What happens:

* Injects imports, provider/listener wiring, and execution method into target page.
* Does not inject popup menu entries or button widgets.
* Generated execution trigger method is intended to be called manually from custom UI widget/button.
* If target page does not exist:
* non-strict mode creates a minimal scaffold page first, then injects
* strict mode fails


* If `--route` is provided, updates module route file with child route + navigation helper while preserving existing base route builder.

Rerun behavior:

* Injection is upsert-style and avoids duplicate snippets.

Strict mode behavior:

* Fails if target page is missing and scaffold creation would be required.

## compose-sec

```bash
fsda compose-sec <slice> -f <feature> -m <module> -a <app> -p <target_page> [--route] [--strict]

```

Injects section composition into a target page.

What happens:

* Injects provider bootstrap and generated execution method.
* Generates a section widget method in the target page.
* If target page does not exist:
* non-strict mode creates a minimal scaffold page first
* strict mode fails


* If `--route` is provided, updates module route file with child route + navigation helper while preserving existing base route builder.
* Section placement in page layout is manual by design.

Rerun behavior:

* Injection is upsert-style and avoids duplicate snippets.

Strict mode behavior:

* Fails if target page is missing and scaffold creation would be required.

## Strict Mode Behavior

When --strict is enabled in compose commands, command fails if:

* target page already exists where generation expects a new page
* required page scaffold would need to be created implicitly
* safe compose anchor patterns are not found
