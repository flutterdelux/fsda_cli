---
id: releases
title: Releases & Migration Notes
slug: /releases
---

This page summarizes documentation channels and behavior changes that matter for daily CLI usage.

## Version Channels

| Channel | Meaning |
| --- | --- |
| `latest` | Current documentation for ongoing development on main branch. |
| `1.0.16` | Stable snapshot for CLI v1.0.16. |

Use the version dropdown in the top-right navbar to switch channels.

## Migration Notes

### Upgrading from legacy compose surface to v1.0.16+

If your old scripts still call a generic compose command, migrate to explicit compose modes:

- `compose-main`
- `compose-form`
- `compose-pag`
- `compose-pmi`
- `compose-sec`

### Safer reruns and strict mode

Generation and composition flows now prioritize non-destructive behavior:

- Existing files are skipped by default to avoid overwrite.
- Use `--strict` to fail immediately when command safety conditions are not met.

### DI and registration behavior

Operational reruns are designed to be incremental:

- `di` appends only missing registration lines.
- `reg` and compose injectors avoid duplicate snippet insertion.
- Commands report affected paths so changes are easy to audit.

## How to Review Changes Before Commit

1. Run commands for your feature flow.
2. Review affected path summary in terminal output.
3. Verify generated files and injected code in the app/module targets.
4. Run `fsda fix-import` for app/module targets when needed.
