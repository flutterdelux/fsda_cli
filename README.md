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
- fsda add-pckg <name> [--hook-disabled]
- fsda gen-app <app>
- fsda gen-module <module> [--hook-disabled]
- fsda gen-feature <feature> -m <module> [--ds <datasource_mode>|--datasource <datasource_mode>] [--hook-disabled]
- fsda regen-feature <feature> -m <module> [--ds <datasource_mode>|--datasource <datasource_mode>]
- fsda slice-m <slice> -f <feature> -m <module> -d <method> [--hook-disabled]
- fsda slice-mp <slice> -f <feature> -m <module> -d <method> --param <prefix_param> --request <prefix_request> [--hook-disabled]
- fsda slice-mr <slice> -f <feature> -m <module> -d <method> [--list] --dto <prefix_dto> --entity <prefix_entity> [--hook-disabled]
- fsda slice-mrp <slice> -f <feature> -m <module> -d <method> [--list] --dto <prefix_dto> --entity <prefix_entity> --param <prefix_param> --request <prefix_request> [--hook-disabled]
- fsda slice-r <slice> -f <feature> -m <module> -d <method> [--list] --dto <prefix_dto> --entity <prefix_entity> [--hook-disabled]
- fsda slice-rof <slice> -f <feature> -m <module> -d <method> [--list] --dto <prefix_dto> --entity <prefix_entity> [--hook-disabled]
- fsda slice-rp <slice> -f <feature> -m <module> -d <method> [--list] --dto <prefix_dto> --entity <prefix_entity> --param <prefix_param> --request <prefix_request> [--hook-disabled]
- fsda slice-rpag <slice> -f <feature> -m <module> -d <method> --dto <prefix_dto> --entity <prefix_entity> --param <prefix_param> --request <prefix_request> [--hook-disabled]
- fsda slice-rs <slice> -f <feature> -m <module> -d <method> [--list] --dto <prefix_dto> --entity <prefix_entity> [--hook-disabled]
- fsda slice-rsp <slice> -f <feature> -m <module> -d <method> [--list] --dto <prefix_dto> --entity <prefix_entity> --param <prefix_param> --request <prefix_request> [--hook-disabled]
- fsda enum <enum_name> -f <feature> -m <module> --values <value_1,value_2,...> [--hook-disabled]
- fsda dto <prefix> -f <feature> -m <module> --props "<type:prop_1,type:prop_2,...>" [--hook-disabled]
- fsda param <prefix> -f <feature> -m <module> --props "<type:prop_1,type:prop_2,...>" [--hook-disabled]
- fsda request <prefix> -f <feature> -m <module> --props "<type:prop_1,type:prop_2,...>" [--hook-disabled]
- fsda entity <prefix> -f <feature> -m <module> --props "<type:prop_1,type:prop_2,...>" [--hook-disabled]
- fsda input-text <field> -f <feature> -m <module> [--hook-disabled]
- fsda input-text-area <field> -f <feature> -m <module> [--min <min_lines>] [--max <max_lines>] [--hook-disabled]
- fsda input-number <field> -f <feature> -m <module> [--type <numeric_type>] [--hook-disabled]
- fsda input-qty <field> -f <feature> -m <module> [--hook-disabled]
- fsda input-dropdown <field> -f <feature> -m <module> --type <value_type> [--hook-disabled]
- fsda input-dropdown-enum <field> -f <feature> -m <module> --type <enum_type> [--hook-disabled]
- fsda input-selector <field> -f <feature> -m <module> --type <entity_type> [--hook-disabled]
- fsda input-selector-list <field> -f <feature> -m <module> --type <entity_type> [--hook-disabled]
- fsda input-image <field> -f <feature> -m <module> --type <value_type> [--hook-disabled]
- fsda input-switch <field> -f <feature> -m <module> [--hook-disabled]
- fsda input-password <field> -f <feature> -m <module> [--hook-disabled]
- fsda ui-main <slice> -f <feature> -m <module> [--hook-disabled]
- fsda ui-dialog <slice> -f <feature> -m <module> [--hook-disabled]
- fsda ui-form <slice> -f <feature> -m <module> --fields "<input_type:value_type:field_name,...>" [--initial <entity_type>] [--hook-disabled]
- fsda ui-form-dialog <slice> -f <feature> -m <module> --fields "<input_type:value_type:field_name,...>" [--initial <entity_type>] [--hook-disabled]
- fsda ui-lsh <slice> -f <feature> -m <module> [--hook-disabled]
- fsda ui-lsv <slice> -f <feature> -m <module> [--hook-disabled]
- fsda ui-pag <slice> -f <feature> -m <module> [--hook-disabled]
- fsda ui-pmi <slice> -f <feature> -m <module> [--hook-disabled]
- fsda ui-action <slice> -f <feature> -m <module> [--hook-disabled]
- fsda ui-sec <slice> -f <feature> -m <module> [--hook-disabled]
- fsda reg <module> -a <app>
- fsda di <module> -a <app>
- fsda rm-reg <module> -a <app>
- fsda rm-feature <feature> -m <module> [--hook-disabled]
- fsda cp-ui <new_slice> -f <feature> -m <module> --from <from_slice>
- fsda refresh <module>
- fsda rebuild <module>
- fsda compose-main <slice> -f <feature> -m <module> -a <app> -p <prefix_target_page> [--route]
- fsda compose-form <slice> -f <feature> -m <module> -a <app> -p <prefix_target_page> [--route]
- fsda compose-form-dialog <slice> -f <feature> -m <module> -a <app> -p <prefix_target_page> [--route]
- fsda compose-pag <slice> -f <feature> -m <module> -a <app> -p <prefix_target_page> [--route]
- fsda compose-pmi <slice> -f <feature> -m <module> -a <app> -p <prefix_target_page> [--route]
- fsda compose-action <slice> -f <feature> -m <module> -a <app> -p <prefix_target_page> [--route]
- fsda compose-sec <slice> -f <feature> -m <module> -a <app> -p <prefix_target_page> [--route]
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

Generation workflow note:

- Use input-* commands first to generate shared field widgets and ARB keys.
- Then use ui-form or ui-form-dialog with --fields for form wiring and composition.
- For ui-form/ui-form-dialog, supported input_type values are: text, number, selector, selector_list, text_area, qty, dropdown, dropdown_enum, image, switch, password.
- ui-form and ui-form-dialog auto-import value types (Entity/Dto/Enum/NetworkFile) based on --fields declarations.
- Naming convention: use snake_case for CLI identifiers (app/module/feature/slice/page/field/enum_name/enum values/typed prop names/slice artifact prefixes).
- Compose rule: pass `--page` as page prefix without `_page` suffix.
- Type rule: `input-dropdown-enum`, `input-selector`, `input-selector-list`, and `input-image` use snake_case type prefixes; `input-dropdown` accepts both Dart type and snake_case alias.
- Modelling rule: typed props keep snake_case input, while generated Dart property identifiers are camelCase.
- Enum special rule: `fsda enum --values` accepts snake_case input, but generated Dart enum members are emitted in camelCase.
- If you use --hook-disabled, FSDA skips post-hook execution and prints manual next-step commands.

Shell note for zsh:

- Always wrap --props values in quotes when nullable type (?) exists, for example "String:id,DateTime?:created_at".

Exit code note:

- 0: success
- 1: runtime or operation failure
- 64: usage error (invalid/missing arguments)

`64` is process status, so it may not appear as a literal output line. Check the last status with:

```bash
echo $?
```

## Compose Notes

- compose-main/form/pag

  build page scaffolds.
  route wiring is optional and only injected when `--route` is provided.
  existing base route builder is preserved if already customized.

- compose-form-dialog

  build form page scaffold using dialog widget as primary UI surface (for showDialog usage).
  route injection is optional via `--route`.

- compose-pmi

  injects popup action/provider/listener/method into existing page.
  route injection is optional via `--route`.

- compose-action

  injects provider/listener/method only for manual custom button placement.
  route injection is optional via `--route`.

- compose-sec

  composes retrieval section style into existing page (provider auto-bootstrap, execution trigger method, section method generation).
  route injection is optional via `--route`.

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
fsda enum modifier_selection_type -f wallet -m finance --values single,multiple
fsda dto Wallet -f wallet -m finance --props "String:id,String:name,ModifierSelectionType:selection_type,int:min_select=0,int:max_select,DateTime?:created_at"
fsda entity Wallet -f wallet -m finance --props "String:id,String:name,ModifierSelectionType:selection_type,int:min_select=0,int:max_select,DateTime?:created_at"
fsda param WalletDetail -f wallet -m finance --props "String:id"
fsda request WalletDetail -f wallet -m finance --props "String:id"
fsda param WalletDelete -f wallet -m finance --props "String:id,String:name"
fsda request WalletDelete -f wallet -m finance --props "String:id,String:name"
fsda slice-rp detail -f wallet -m finance -d getWalletDetail --dto wallet --entity wallet --param wallet_detail --request wallet_detail
fsda slice-mp delete -f wallet -m finance -d deleteWallet --param wallet_delete --request wallet_delete
fsda param WalletCreate -f wallet -m finance --props "String:id,String:name,ModifierSelectionType:selection_type,int:min_select=0,int:max_select"
fsda request WalletCreate -f wallet -m finance --props "String:id,String:name,ModifierSelectionType:selection_type,int:min_select=0,int:max_select"
fsda entity WalletSummary -f wallet -m finance --props "String:id,String:name"

fsda input-text name -f wallet -m finance
fsda input-text-area notes -f wallet -m finance --min 3 --max 6
fsda input-number price -f wallet -m finance --type double
fsda input-qty min_select -f wallet -m finance
fsda input-qty max_select -f wallet -m finance
fsda input-dropdown-enum selection_type -f wallet -m finance --type modifier_selection_type
fsda input-dropdown category -f wallet -m finance --type wallet_category_entity
fsda input-selector parent_wallet -f wallet -m finance --type wallet
fsda input-selector-list related_wallets -f wallet -m finance --type wallet
fsda input-image wallet_image -f wallet -m finance --type network_file
fsda input-switch is_active -f wallet -m finance
fsda input-password password -f wallet -m finance

fsda ui-main detail -f wallet -m finance
fsda ui-pmi delete -f wallet -m finance
fsda ui-dialog delete -f wallet -m finance
fsda ui-action delete -f wallet -m finance
fsda ui-form create -f wallet -m finance --fields "text:String:name,dropdown_enum:ModifierSelectionType:selection_type,dropdown:WalletCategoryEntity:category,qty:int:min_select,qty:int:max_select"
fsda ui-form-dialog update -f wallet -m finance --fields "text:String:name,dropdown_enum:ModifierSelectionType:selection_type,dropdown:WalletCategoryEntity:category,qty:int:min_select,qty:int:max_select" --initial WalletEntity

fsda reg finance -a demo_app
fsda di finance -a demo_app

fsda compose-main detail -f wallet -m finance -a demo_app -p wallet_detail
fsda compose-form-dialog update -f wallet -m finance -a demo_app -p wallet_update
fsda compose-pmi delete -f wallet -m finance -a demo_app -p wallet_detail
fsda compose-action delete -f wallet -m finance -a demo_app -p wallet_edit

# Quick hook sync after --hook-disabled:
fsda refresh finance
# Full module reset when needed:
fsda rebuild finance

fsda fix-import -a demo_app
```
