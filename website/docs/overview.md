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
  compose commands are explicit by mode (main, form, form-dialog, dialog, pag, pmi, action, sec).
- Flexible automation:
  post-hooks can be deferred with `--hook-disabled` for manual execution timing.

## Command Surface

High-level command groups:

- Workspace setup: create, configure, configure-app
- Package operations: list-pckg, add-pckg
- Generation (core): gen-app, gen-module, gen-feature, regen-feature
- Slice generation: slice-m, slice-mp, slice-mr, slice-mrp, slice-r, slice-rof, slice-rp, slice-rpag, slice-rs, slice-rsp
- Modelling: enum, dto, entity, param, request
- Shared input: input-text, input-text-area, input-number, input-qty, input-dropdown, input-dropdown-enum, input-selector, input-selector-list, input-image, input-switch, input-password
- UI generation: ui-main, ui-dialog, ui-form, ui-form-dialog, ui-lsh, ui-lsv, ui-pag, ui-pmi, ui-action, ui-sec
- Registration: reg, di, rm-reg
- Composition: compose-main, compose-form, compose-form-dialog, compose-dialog, compose-pag, compose-pmi, compose-action, compose-sec
- Maintenance: rm-feature, cp-ui, refresh, rebuild, fix-import

Continue to Installation for prerequisites and setup steps.

After that, use Releases & Migration Notes to understand version-to-version behavior changes.
