---
id: installation
title: Installation
slug: /installation
---

## Prerequisites

Before installing FSDA CLI, make sure your environment has:

- Dart SDK
- Flutter SDK

## Install Globally

```bash
dart pub global activate fsda_cli
```

Verify installation:

```bash
fsda --version
```

## Workspace Rule

Most commands must run from a workspace root containing fsda.yaml.

Commands allowed outside a workspace root:

- fsda create `<workspace_name>`

## Quick Start

```bash
fsda create fsda_base
cd fsda_base
fsda configure

fsda list-pckg
fsda add-pckg app_core
fsda add-pckg infra_dio

fsda gen-app demo_app
fsda configure-app demo_app

fsda gen-module finance
fsda gen-feature wallet -m finance --ds remote --base-path "/wallets"
fsda enum modifier_selection_type -f wallet -m finance --values single,multiple
fsda dto wallet_dto -f wallet -m finance --props "String:id,String:name,ModifierSelectionType:selection_type,int:min_select=0,int:max_select,DateTime?:created_at"
fsda entity wallet_entity -f wallet -m finance --props "String:id,String:name,ModifierSelectionType:selection_type,int:min_select=0,int:max_select,DateTime?:created_at"
fsda param wallet_detail_param -f wallet -m finance --props "String:id"
fsda request wallet_detail_request -f wallet -m finance --props "String:id"
fsda param wallet_delete_param -f wallet -m finance --props "String:id,String:name"
fsda request wallet_delete_request -f wallet -m finance --props "String:id,String:name"
fsda slice-rp detail -f wallet -m finance -d getWalletDetail --dto wallet_dto --entity wallet_entity --param wallet_detail_param --request wallet_detail_request
fsda slice-mp delete -f wallet -m finance -d deleteWallet --param wallet_delete_param --request wallet_delete_request
fsda param wallet_create_param -f wallet -m finance --props "String:id,String:name,ModifierSelectionType:selection_type,int:min_select=0,int:max_select"
fsda request wallet_create_request -f wallet -m finance --props "String:id,String:name,ModifierSelectionType:selection_type,int:min_select=0,int:max_select"
fsda entity wallet_summary_entity -f wallet -m finance --props "String:id,String:name"

fsda input-text name -f wallet -m finance
fsda input-text-area notes -f wallet -m finance --min 3 --max 6
fsda input-number price -f wallet -m finance --type double
fsda input-qty min_select -f wallet -m finance
fsda input-qty max_select -f wallet -m finance
fsda input-dropdown-enum selection_type -f wallet -m finance --type modifier_selection_type
fsda input-dropdown category -f wallet -m finance --type wallet_category_entity
fsda input-selector parent_wallet -f wallet -m finance --type wallet_entity
fsda input-selector-list related_wallets -f wallet -m finance --type wallet_entity
fsda input-image wallet_image -f wallet -m finance --type network_file
fsda input-switch is_active -f wallet -m finance
fsda input-password password -f wallet -m finance

fsda ui-main detail -f wallet -m finance
fsda ui-pmi delete -f wallet -m finance
fsda ui-dialog delete -f wallet -m finance
fsda ui-action delete -f wallet -m finance
fsda ui-form create -f wallet -m finance --fields "text:String:name,dropdown_enum:ModifierSelectionType:selection_type,dropdown:WalletCategoryEntity:category,qty:int:min_select,qty:int:max_select" --type wallet_entity
fsda ui-form-dialog update -f wallet -m finance --fields "text:String:name,dropdown_enum:ModifierSelectionType:selection_type,dropdown:WalletCategoryEntity:category,qty:int:min_select,qty:int:max_select" --type wallet_entity --initial

fsda reg finance -a demo_app
fsda di finance -a demo_app

fsda compose-main detail -f wallet -m finance -a demo_app -p wallet_detail_page
fsda compose-form-dialog update -f wallet -m finance -a demo_app -p wallet_update_page
fsda compose-pmi delete -f wallet -m finance -a demo_app -p wallet_detail_page
fsda compose-dialog delete -f wallet -m finance -a demo_app -p wallet_delete_page

# optional helper after hook-disabled workflow:
fsda refresh finance
# full rebuild when module build state is stale:
fsda rebuild finance

fsda fix-import -a demo_app
```

zsh note:

- Quote `--props` values when nullable type (`?`) exists.
- CLI identifiers use snake_case (`app`, `module`, `feature`, `slice`, `page`, `field`, enum name/value, prop names, and artifact names).
- Modelling and slice commands use complete artifact names, including their `_dto`, `_entity`, `_param`, and `_request` suffixes.
- Compose `--page` takes the complete target page name, such as `wallet_detail_page`.
- Input type artifact names use snake_case; Entity inputs include `_entity`.
- Enum special rule: `fsda enum --values` menerima snake_case, tetapi member enum yang dihasilkan di Dart akan menjadi camelCase.

## Strict Mode

Several generation and composition commands support --strict.

In strict mode, command execution fails when it detects unsafe situations like:

- target file already exists and would be skipped
- required injection anchor is missing
- implicit scaffold creation would be required in flows that should remain explicit

## Hook Skip Option

Commands that execute post-hooks support `--hook-disabled`.

When enabled, FSDA CLI will:

- skip post-hook execution
- print manual next-step commands so you can run hooks later

## Exit Codes

FSDA CLI uses process exit codes:

- `0` for success
- `1` for runtime or operation failures
- `64` for usage errors (invalid/missing arguments)

The value `64` is emitted as process status and may not appear as a literal line in output. In zsh/bash, inspect the latest status with:

```bash
echo $?
```
