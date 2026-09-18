---
id: commands-index
title: Commands
slug: /commands
---

This section documents command behavior by real side effects.

## Execution Context

- Run commands from a workspace root containing `fsda.yaml`.
- The only command designed for outside workspace execution is `fsda create <workspace_name>`.
- Most generation/composition/registration flows print affected path summaries (`created`, `injected`, `removed`, `skipped`).

## Command Groups

| Group | Includes | Details |
| --- | --- | --- |
| Workspace Commands | `create`, `configure`, `configure-app`, `list-pckg`, `add-pckg` | Open "Workspace Commands" from sidebar |
| Generation Commands | `gen-app`, `gen-module`, `gen-feature`, `regen-feature` | Open "Generation Commands" from sidebar |
| Slice Commands | `slice-m`, `slice-mp`, `slice-mr`, `slice-mrp`, `slice-r`, `slice-rof`, `slice-rp`, `slice-rpag`, `slice-rs`, `slice-rsp` | Open "Slice Commands" from sidebar |
| Modelling Commands | `enum`, `dto`, `entity`, `param`, `request` | Open "Modelling Commands" from sidebar |
| Input Commands | `input-text`, `input-text-area`, `input-number`, `input-qty`, `input-dropdown`, `input-dropdown-enum`, `input-selector`, `input-selector-list`, `input-image`, `input-switch`, `input-password` | Open "Input Commands" from sidebar |
| UI Commands | `ui-main`, `ui-dialog`, `ui-form`, `ui-form-dialog`, `ui-lsh`, `ui-lsv`, `ui-pag`, `ui-pmi`, `ui-action`, `ui-sec` | Open "UI Commands" from sidebar |
| Composition Commands | `compose-main`, `compose-form`, `compose-form-dialog`, `compose-dialog`, `compose-pag`, `compose-pmi`, `compose-action`, `compose-sec` | Open "Composition Commands" from sidebar |
| Maintenance Commands | `reg`, `di`, `rm-reg`, `rm-feature`, `cp-ui`, `rebuild`, `refresh`, `fix-import` | Open "Maintenance Commands" from sidebar |

## Commands With Strict Mode

- `enum`
- `dto`
- `param`
- `entity`
- `request`
- `input-text`
- `input-text-area`
- `input-number`
- `input-qty`
- `input-dropdown`
- `input-dropdown-enum`
- `input-selector`
- `input-selector-list`
- `input-image`
- `input-switch`
- `input-password`
- `ui-main`
- `ui-dialog`
- `ui-form`
- `ui-form-dialog`
- `ui-lsh`
- `ui-lsv`
- `ui-pag`
- `ui-pmi`
- `ui-action`
- `ui-sec`
- `reg`
- `di`
- `compose-main`
- `compose-form`
- `compose-form-dialog`
- `compose-dialog`
- `compose-pag`
- `compose-pmi`
- `compose-action`
- `compose-sec`

## Commands With Hook Skip

Commands below support `--hook-disabled` and skip post-hooks while printing manual next-step commands:

- `configure`
- `add-pckg`
- `gen-module`
- `gen-feature`
- `slice-m`
- `slice-mp`
- `slice-mr`
- `slice-mrp`
- `slice-r`
- `slice-rof`
- `slice-rp`
- `slice-rpag`
- `slice-rs`
- `slice-rsp`
- `enum`
- `dto`
- `param`
- `entity`
- `request`
- `input-text`
- `input-text-area`
- `input-number`
- `input-qty`
- `input-dropdown`
- `input-dropdown-enum`
- `input-selector`
- `input-selector-list`
- `input-image`
- `input-switch`
- `input-password`
- `ui-main`
- `ui-dialog`
- `ui-form`
- `ui-form-dialog`
- `ui-lsh`
- `ui-lsv`
- `ui-pag`
- `ui-pmi`
- `ui-action`
- `ui-sec`
- `rm-feature`

## Exit Codes

FSDA CLI uses process exit codes:

- `0`: success
- `1`: runtime/operation failure
- `64`: usage error (invalid or missing arguments)

`64` may not appear as a literal output line because it is emitted as process status. Check it with:

```bash
echo $?
```
