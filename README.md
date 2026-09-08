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

## Documentation

For detailed usage instructions and guides, please refer to the [FSDA CLI Documentation](https://flutterdelux.github.io/fsda_cli/).

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
- fsda gen-slice <slice> -f <feature> -m <module> -s <sequence_code> [-d <method>]
- fsda gen-enum <enum_name> -f <feature> -m <module> --values <value_1,value_2,...>
- fsda ui-main <slice> -f <feature> -m <module>
- fsda ui-dialog <slice> -f <feature> -m <module>
- fsda ui-form <slice> -f <feature> -m <module> --fields <field_1,field_2,...>
- fsda ui-form-dialog <slice> -f <feature> -m <module> --fields <field_1,field_2,...>
- fsda ui-lsh <slice> -f <feature> -m <module>
- fsda ui-lsv <slice> -f <feature> -m <module>
- fsda ui-pag <slice> -f <feature> -m <module>
- fsda ui-pmi <slice> -f <feature> -m <module>
- fsda ui-action <slice> -f <feature> -m <module>
- fsda ui-sec <slice> -f <feature> -m <module>
- fsda gen-ui <slice> -f <feature> -m <module> -u <ui_code> (legacy)
- fsda reg <module> -a <app>
- fsda di <module> -a <app> [-f <feature>]
- fsda rm-reg <module> -a <app>
- fsda compose-main <slice> -f <feature> -m <module> -a <app> -p <target_page>
- fsda compose-form <slice> -f <feature> -m <module> -a <app> -p <target_page>
- fsda compose-form-dialog <slice> -f <feature> -m <module> -a <app> -p <target_page>
- fsda compose-pag <slice> -f <feature> -m <module> -a <app> -p <target_page>
- fsda compose-pmi <slice> -f <feature> -m <module> -a <app> -p <target_page>
- fsda compose-action <slice> -f <feature> -m <module> -a <app> -p <target_page>
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

- main
- dialog
- form
- form_dialog
- lsh
- lsv
- pag
- pmi
- action
- sec

Recommended UI command mapping:

- main -> fsda ui-main
- dialog -> fsda ui-dialog
- form -> fsda ui-form
- form_dialog -> fsda ui-form-dialog
- lsh -> fsda ui-lsh
- lsv -> fsda ui-lsv
- pag -> fsda ui-pag
- pmi -> fsda ui-pmi
- action -> fsda ui-action
- sec -> fsda ui-sec

Legacy compatibility:

- fsda gen-ui is still available in v1.1.0 and prints a migration hint.

## Compose Notes

- compose-main/form/pag

  build page scaffolds and sync route wiring.
  Existing base route builder is preserved if already customized.

- compose-form-dialog

  build form page scaffold using dialog widget as primary UI surface (for showDialog usage, no route injection).

- compose-pmi

  injects popup action/provider/listener/method into existing page.

- compose-action

  injects provider/listener/method only for manual custom button placement.

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
fsda gen-slice detail -f wallet -m finance -s Rp
fsda gen-slice delete -f wallet -m finance -s Mp
fsda gen-enum modifier_selection_type -f wallet -m finance --values single,multiple

fsda ui-main detail -f wallet -m finance
fsda ui-pmi delete -f wallet -m finance
fsda ui-dialog delete -f wallet -m finance
fsda ui-action delete -f wallet -m finance
fsda ui-form create -f wallet -m finance --fields title,description
fsda ui-form-dialog update -f wallet -m finance --fields name,type

fsda reg finance -a demo_app
fsda di finance -a demo_app

fsda compose-main detail -f wallet -m finance -a demo_app -p wallet_detail_page
fsda compose-form-dialog update -f wallet -m finance -a demo_app -p wallet_update_page
fsda compose-pmi delete -f wallet -m finance -a demo_app -p wallet_detail_page
fsda compose-action delete -f wallet -m finance -a demo_app -p wallet_edit_page

fsda fix-import -a demo_app
```
