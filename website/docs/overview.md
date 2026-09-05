---
id: overview
title: Overview
slug: /overview
---

FSDA CLI is a command-line tool for building and maintaining Flutter workspaces using Feature Slice Driven Architecture.

## What You Can Do

- Create a new FSDA workspace skeleton.
- Configure shared workspace packages from fsda.yaml.
- Generate apps, modules, features, slices, and UI templates.
- Compose generated feature slices into app pages and routes.
- Register and remove module wrappers into/from applications.
- Keep generated output auditable with affected-path summaries.
- Track behavior changes using release and migration notes.

## Design Principles

- Safe-by-default generation:
  existing files are skipped to prevent overwrite.
- Idempotent injection:
  rerunning commands should only add missing parts.
- Visibility-first execution:
  key commands print created, injected, removed, and skipped paths.
- Structured composition:
  compose commands are explicit by mode (main, form, pag, pmi, sec).

## Command Surface

High-level command groups:

- Workspace setup: create, configure, configure-app
- Package operations: list-pckg, add-pckg
- Generation: gen-app, gen-module, gen-feature, regen-feature, gen-slice, gen-ui
- Registration: reg, di, rm-reg
- Composition: compose-main, compose-form, compose-pag, compose-pmi, compose-sec
- Maintenance: fix-import

Continue to Installation for prerequisites and setup steps.

After that, use Releases & Migration Notes to understand version-to-version behavior changes.
