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
fsda gen-feature wallet -m finance --ds remote
fsda gen-slice detail -f wallet -m finance -s Rp -u main
fsda gen-slice delete -f wallet -m finance -s Mp -u pmi,dialog

fsda reg finance -a demo_app
fsda di wallet -m finance -a demo_app

fsda compose-main detail -f wallet -m finance -a demo_app -p wallet_detail_page
fsda compose-pmi delete -f wallet -m finance -a demo_app -p wallet_detail_page

fsda fix-import -a demo_app
```

## Strict Mode

Several generation and composition commands support --strict.

In strict mode, command execution fails when it detects unsafe situations like:

- target file already exists and would be skipped
- required injection anchor is missing
- implicit scaffold creation would be required in flows that should remain explicit
