---
id: commands-composition
title: Composition Commands
---

Composition commands integrate generated feature slices into app pages and routes.

## compose-main

```bash
fsda compose-main <slice> -f <feature> -m <module> -a <app> -p <target_page> [--strict]
```

Creates a main page composition flow and syncs base route + child route.

## compose-form

```bash
fsda compose-form <slice> -f <feature> -m <module> -a <app> -p <target_page> [--strict]
```

Creates a form-based page composition flow and syncs base route + child route.

## compose-pag

```bash
fsda compose-pag <slice> -f <feature> -m <module> -a <app> -p <target_page> [--strict]
```

Creates a pagination page composition flow.

## compose-pmi

```bash
fsda compose-pmi <slice> -f <feature> -m <module> -a <app> -p <target_page> [--strict]
```

Injects popup menu action + required provider/listener/method wiring to target page.

## compose-sec

```bash
fsda compose-sec <slice> -f <feature> -m <module> -a <app> -p <target_page> [--strict]
```

Injects section composition with provider bootstrap and execution trigger method.

## Strict Mode Behavior

When --strict is enabled in compose commands, command fails if:

- target page already exists where generation expects a new page
- required page scaffold would need to be created implicitly
- safe compose anchor patterns are not found
