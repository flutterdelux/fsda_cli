---
id: commands-index
title: Commands
slug: /commands
---

This section documents command behavior by real side effects.

For each command group, the focus is:

- what files/folders are created
- what code is injected/modified
- what gets skipped on rerun
- what changes when `--strict` is enabled

## Execution Context

- Run commands from the workspace root that contains `fsda.yaml`.
- The only command designed to run outside an existing workspace is `fsda create <workspace_name>`.
- Most generation/composition/registration flows print affected path summaries (`created`, `injected`, `removed`, `skipped`).

## Command Groups

| Group | Includes | Details |
| --- | --- | --- |
| Workspace Commands | `create`, `configure`, `configure-app`, `list-pckg`, `add-pckg` | Open "Workspace Commands" from sidebar |
| Generation Commands | `gen-app`, `gen-module`, `gen-feature`, `regen-feature`, `gen-slice`, `gen-ui` | Open "Generation Commands" from sidebar |
| Composition Commands | `compose-main`, `compose-form`, `compose-pag`, `compose-pmi`, `compose-sec` | Open "Composition Commands" from sidebar |
| Maintenance Commands | `reg`, `di`, `rm-reg`, `fix-import` | Open "Maintenance Commands" from sidebar |

## Commands With Strict Mode

- `gen-slice`
- `gen-ui`
- `reg`
- `di`
- `compose-main`
- `compose-form`
- `compose-pag`
- `compose-pmi`
- `compose-sec`

Use the sidebar pages for grouped details and examples.
