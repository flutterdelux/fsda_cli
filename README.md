# FSDA CLI

Feature Slice Driven Architecture CLI for workspace scaffolding and code generation.

## 🚀 Installation

Before installing FSDA CLI, make sure your computer has:
* **Dart SDK**
* **Flutter SDK**

Then, run the following command to install FSDA CLI globally:

```bash
dart pub global activate fsda_cli
```

## Workspace Rule

Run most commands from workspace root containing fsda.yaml.

Commands requiring workspace root:

- fsda configure
- fsda configure-app <app>
- fsda list-pckg
- fsda add-pckg <name>
- fsda gen-app <app>
- fsda gen-module <module>
- fsda gen-feature <feature> -m <module> [--ds <datasource_mode>]
- fsda regen-feature <feature> -m <module> [--ds <datasource_mode>]
- fsda gen-slice <slice> -f <feature> -m <module> -s <sequence_code> [-d <method>] [-u <ui_code>]...
- fsda gen-ui <slice> -f <feature> -m <module> -u <ui_code>
- fsda reg <module> -a <app>
- fsda di <feature> -m <module> -a <app>
- fsda rm-reg <module> -a <app>
- fsda compose-main <slice> -f <feature> -m <module> -a <app> -p <target_page>
- fsda compose-form <slice> -f <feature> -m <module> -a <app> -p <target_page>
- fsda compose-pag <slice> -f <feature> -m <module> -a <app> -p <target_page>
- fsda compose-pmi <slice> -f <feature> -m <module> -a <app> -p <target_page>
- fsda compose-sec <slice> -f <feature> -m <module> -a <app> -p <target_page>
- fsda fix-import [-m <module>] [-a <app>]

Command allowed outside workspace root:

- fsda create <workspace>

## Supported Sequence Templates

- M
- Mp
- Mr
- Mrp
- R
- Rp
- Rpag
- Rs
- Rsp
- Rof

## Supported UI Codes

- detail
- dialog
- form
- lsh
- lsv
- pag
- pmi
- sec

## Compose Notes

- compose-main/form/pag

  build page scaffolds and sync route wiring.

- compose-pmi

  injects popup action/provider/listener/method into existing page.

- compose-sec

  composes retrieval section style into existing page (provider auto-bootstrap, execution trigger method, section method generation).

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
fsda gen-slice detail -f wallet -m finance -s Rp -u detail
fsda gen-slice delete -f wallet -m finance -s Mp -u pmi,dialog

fsda reg finance -a demo_app
fsda di wallet -m finance -a demo_app

fsda compose-main detail -f wallet -m finance -a demo_app -p wallet_detail_page
fsda compose-pmi delete -f wallet -m finance -a demo_app -p wallet_detail_page

fsda fix-import -a demo_app
```
