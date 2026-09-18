---
id: workflow
title: Workflow
slug: /workflow
---

This page describes a practical end-to-end workflow from a fresh workspace to composed app pages.

## 1. Initialize Workspace

```bash
fsda create fsda_base
cd fsda_base
fsda configure
```

## 2. Configure Packages

```bash
fsda list-pckg
fsda add-pckg app_core
fsda add-pckg infra_dio
```

## 3. Generate App and Module

```bash
fsda gen-app demo_app
fsda configure-app demo_app

fsda gen-module finance
```

## 4. Generate Feature and Slice

```bash
fsda gen-feature wallet -m finance --ds remote
fsda slice-m delete -f wallet -m finance -d deleteWallet
fsda slice-mp create -f wallet -m finance -d createWallet --props "String:id,String:name"
fsda enum modifier_selection_type -f wallet -m finance --values single,multiple
fsda dto Wallet -f wallet -m finance --props "String:id,String:name,ModifierSelectionType:selectionType,int:minSelect=0,int:maxSelect,DateTime?:createdAt"
fsda entity Wallet -f wallet -m finance --props "String:id,String:name,ModifierSelectionType:selectionType,int:minSelect=0,int:maxSelect,DateTime?:createdAt"
fsda slice-mr sync -f wallet -m finance -d syncWallets --list --model Wallet
fsda slice-r detail -f wallet -m finance -d getWalletDetail --model Wallet
fsda slice-rp list -f wallet -m finance -d getWalletList --list --model Wallet --props "int:page=1,int:limit=20"
fsda slice-rof catalog -f wallet -m finance -d getWalletCatalog --list --model Wallet
fsda slice-rpag list -f wallet -m finance -d getWalletList --model Wallet --props "int:page=1,int:pageSize=15,String?:query"
fsda slice-rs watch -f wallet -m finance -d watchWallet --model Wallet
fsda slice-rsp watch_all -f wallet -m finance -d watchWallets --list --model Wallet --props "String:id"
fsda param WalletCreate -f wallet -m finance --props "String:id,String:name,ModifierSelectionType:selectionType,int:minSelect=0,int:maxSelect"
fsda request WalletCreate -f wallet -m finance --props "String:id,String:name,ModifierSelectionType:selectionType,int:minSelect=0,int:maxSelect"
fsda entity wallet_summary -f wallet -m finance --props "String:id,String:name"

fsda input-text name -f wallet -m finance
fsda input-text-area notes -f wallet -m finance --min 3 --max 6
fsda input-number price -f wallet -m finance --type double
fsda input-qty min_select -f wallet -m finance
fsda input-qty max_select -f wallet -m finance
fsda input-dropdown-enum selection_type -f wallet -m finance --type ModifierSelectionType
fsda input-dropdown category -f wallet -m finance --type WalletCategoryEntity
fsda input-selector parent_wallet -f wallet -m finance --type WalletEntity
fsda input-selector-list related_wallets -f wallet -m finance --type WalletEntity
fsda input-image wallet_image -f wallet -m finance
fsda input-switch is_active -f wallet -m finance
fsda input-password password -f wallet -m finance

fsda ui-main detail -f wallet -m finance
fsda ui-pmi delete -f wallet -m finance
fsda ui-dialog delete -f wallet -m finance
fsda ui-action delete -f wallet -m finance
fsda ui-form create -f wallet -m finance --fields "text:String:name,dropdown_enum:ModifierSelectionType:selection_type,dropdown:WalletCategoryEntity:category,qty:int:min_select,qty:int:max_select"
fsda ui-form-dialog update -f wallet -m finance --fields "text:String:name,dropdown_enum:ModifierSelectionType:selection_type,dropdown:WalletCategoryEntity:category,qty:int:min_select,qty:int:max_select" --initial WalletEntity
```

Notes:

- `input-*` commands generate shared field widgets and field-level ARB keys.
- `ui-form` and `ui-form-dialog` now focus on form wiring/call syntax and do not generate shared field widgets.
- Use `fsda refresh <module>` after hook-disabled workflows for quick `gen-l10n` + `build_runner` sync.
- Use `fsda rebuild <module>` for full module reset (`clean`, `pub get`, `gen-l10n`, `build_runner`).
- In zsh, quote `--props` values when nullable type (`?`) exists.
- Use `--hook-disabled` when you want to defer post-hook execution and run it manually later.

## 5. Register and DI Sync

```bash
fsda reg finance -a demo_app
fsda di finance -a demo_app
```

## 6. Compose Into App Pages

```bash
fsda compose-main detail -f wallet -m finance -a demo_app -p wallet_detail_page
fsda compose-form-dialog update -f wallet -m finance -a demo_app -p wallet_update_page
fsda compose-pmi delete -f wallet -m finance -a demo_app -p wallet_detail_page
fsda compose-dialog delete -f wallet -m finance -a demo_app -p wallet_delete_page
```

## 7. Run Maintenance

```bash
fsda fix-import -a demo_app
# Optional cleanup when a feature is no longer needed:
fsda rm-feature wallet_legacy -m finance
# Tip: add --hook-disabled if you want to run hooks manually later.
```

## Suggested Team Conventions

- Use --strict in CI or protected branches.
- Treat generated files as baseline, custom logic as additive layers.
- Review affected-path summary output after each compose/reg/di command.
