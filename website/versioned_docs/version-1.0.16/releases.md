---
id: releases
title: Releases & Migration Notes
slug: /releases
---

This page documents release notes for the `1.0.16` documentation snapshot.

## Snapshot: 1.0.16

Highlights in this line:

- Typed compose command surface (`compose-main`, `compose-form`, `compose-pag`, `compose-pmi`, `compose-sec`).
- Non-destructive generation defaults for existing files.
- `--strict` support in generation/composition/registration flows for fail-fast safety.
- Affected path summaries for better auditability after command execution.

## Migration Notes from older flow

1. Replace legacy compose entry usage with explicit compose mode commands.
2. Expect reruns to skip existing generated files by default.
3. Use `--strict` in CI/protected branches to fail unsafe or ambiguous injection states.
4. Prefer reviewing affected path summaries after `reg`, `di`, and compose pipelines.
