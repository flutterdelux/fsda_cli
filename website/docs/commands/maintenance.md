---
id: commands-maintenance
title: Maintenance Commands
---

## reg

```bash
fsda reg <module> -a <app> [--strict]
```

Registers module wrapper and injects integration points into app.

## di

```bash
fsda di <feature> -m <module> -a <app> [--strict]
```

Synchronizes feature DI registration into module DI wrapper.

This flow is incremental and idempotent:

- existing custom code is preserved
- only missing registrations are appended

## rm-reg

```bash
fsda rm-reg <module> -a <app>
```

Removes module registration and cleans injected references.

## fix-import

```bash
fsda fix-import [-m <module>] [-a <app>]
```

Runs automatic import ordering and unused import cleanup.
