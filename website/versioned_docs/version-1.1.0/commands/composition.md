---
id: commands-composition
title: Composition Commands
---

Composition commands integrate generated feature slices into app pages and routes.

## Shared Preconditions

- Run from workspace root.
- Target module wrapper in app must already exist (`fsda reg <module> -a <app>`).
- Target feature and slice logic must exist.
- Module route file `apps/<app>/lib/modules/<module>/<module>_route.dart` must exist.

## compose-main

```bash
fsda compose-main <slice> -f <feature> -m <module> -a <app> -p <target_page> [--strict]
```

Creates a new view-driven page composition and syncs route wiring.

What happens:

- Requires a view under `modules/<module>/lib/src/features/<feature>/ui/<slice>/views`.
- Generates page file: `apps/<app>/lib/modules/<module>/features/<feature>/pages/<target_page>.dart`.
- Injects provider/listener wiring based on detected logic class.
- Updates module route file with child route + navigation helper while preserving existing base route builder.
- Prints affected paths summary.

Rerun behavior:

- If target page already exists, page generation is skipped.
- Route update runs idempotently.

Strict mode behavior:

- Fails when target page already exists.

## compose-form

```bash
fsda compose-form <slice> -f <feature> -m <module> -a <app> -p <target_page> [--strict]
```

Creates a form-style page composition and syncs route wiring.

What happens:

- Same pipeline as `compose-main`, but generated page scaffold is form-oriented.
- Updates module route file with child route + navigation helper while preserving existing base route builder.

Rerun behavior:

- If target page already exists, page generation is skipped.
- Route update runs idempotently.

Strict mode behavior:

- Fails when target page already exists.

## compose-form-dialog

```bash
fsda compose-form-dialog <slice> -f <feature> -m <module> -a <app> -p <target_page> [--strict]
```

Creates a dialog-based form composition for showDialog() usage without route wiring.

What happens:

- Uses generated dialog widget (`..._dialog.dart`) as primary page surface.
- Reuses form cubit/form widget flow from feature slice logic.
- Generates the target page scaffold only (no module route update).

Rerun behavior:

- If target page already exists, page generation is skipped.
- Route update is intentionally skipped.

Strict mode behavior:

- Fails when target page already exists.

## compose-pag

```bash
fsda compose-pag <slice> -f <feature> -m <module> -a <app> -p <target_page> [--strict]
```

Creates a pagination page composition flow.

What happens:

- Requires view scaffold and pagination content widget from the slice UI.
- Generates page file in app module feature pages directory.
- Builds pagination wiring (refresh/loadMore behavior based on detected logic methods/state shape).
- Updates module route file with child route + navigation helper while preserving existing base route builder.

Rerun behavior:

- If target page already exists, page generation is skipped.
- Route update runs idempotently.

Strict mode behavior:

- Fails when target page already exists.

## compose-pmi

```bash
fsda compose-pmi <slice> -f <feature> -m <module> -a <app> -p <target_page> [--strict]
```

Injects popup menu action flow into a target page.

What happens:

- Looks for popup menu item widget from slice UI widgets.
- Injects imports, provider/listener wiring, execution method, and popup action handler into target page.
- If target page does not exist:
	- non-strict mode creates a minimal scaffold page first, then injects
	- strict mode fails
- Updates module route file with child route + navigation helper while preserving existing base route builder.

Rerun behavior:

- Injection is upsert-style and avoids duplicate snippets.

Strict mode behavior:

- Fails if target page is missing and scaffold creation would be required.

## compose-action

```bash
fsda compose-action <slice> -f <feature> -m <module> -a <app> -p <target_page> [--strict]
```

Injects action logic flow into a target page without injecting button placement.

What happens:

- Injects imports, provider/listener wiring, and execution method into target page.
- Does not inject popup menu entries or button widgets.
- Generated execution trigger method is intended to be called manually from custom UI widget/button.
- If target page does not exist:
	- non-strict mode creates a minimal scaffold page first, then injects
	- strict mode fails
- Updates module route file with child route + navigation helper while preserving existing base route builder.

Rerun behavior:

- Injection is upsert-style and avoids duplicate snippets.

Strict mode behavior:

- Fails if target page is missing and scaffold creation would be required.

## compose-sec

```bash
fsda compose-sec <slice> -f <feature> -m <module> -a <app> -p <target_page> [--strict]
```

Injects section composition into a target page.

What happens:

- Injects provider bootstrap and generated execution method.
- Generates a section widget method in the target page.
- If target page does not exist:
	- non-strict mode creates a minimal scaffold page first
	- strict mode fails
- Updates module route file with child route + navigation helper while preserving existing base route builder.
- Section placement in page layout is manual by design.

Rerun behavior:

- Injection is upsert-style and avoids duplicate snippets.

Strict mode behavior:

- Fails if target page is missing and scaffold creation would be required.

## Strict Mode Behavior

When --strict is enabled in compose commands, command fails if:

- target page already exists where generation expects a new page
- required page scaffold would need to be created implicitly
- safe compose anchor patterns are not found
