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
fsda gen-slice detail -f wallet -m finance -s Rp -u main
fsda gen-slice delete -f wallet -m finance -s Mp -u pmi,dialog
```

## 5. Register and DI Sync

```bash
fsda reg finance -a demo_app
fsda di wallet -m finance -a demo_app
```

## 6. Compose Into App Pages

```bash
fsda compose-main detail -f wallet -m finance -a demo_app -p wallet_detail_page
fsda compose-pmi delete -f wallet -m finance -a demo_app -p wallet_detail_page
```

## 7. Run Maintenance

```bash
fsda fix-import -a demo_app
```

## Suggested Team Conventions

- Use --strict in CI or protected branches.
- Treat generated files as baseline, custom logic as additive layers.
- Review affected-path summary output after each compose/reg/di command.
