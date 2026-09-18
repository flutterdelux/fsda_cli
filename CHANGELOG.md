## 2.0.0

- breaking:
    - remove legacy `gen-ui` command from active command surface. Use dedicated `ui-*` commands.
    - remove legacy `gen-slice` command from active command surface. Use dedicated `slice-*` commands.
    - `di` command is now fixed to module scope only: `fsda di <module> -a <app> [--strict]`.
    - `ui-form` and `ui-form-dialog` with `--fields` no longer generate shared field widgets or field ARB keys.
    - all `input-*` commands now use single-field mode (`<field>` or `--field`) per command run.
    - `ui-form` / `ui-form-dialog` input_type values are fixed to snake_case tokens: `text`, `selector`, `selector_list`, `text_area`, `qty`, `dropdown`, `dropdown_enum`, `image`, `switch`, `password`.
- add:
    - dedicated slice command surface:
        - slice-m
        - slice-mp
        - slice-mr
        - slice-mrp
        - slice-r
        - slice-rof
        - slice-rp
        - slice-rpag
        - slice-rs
        - slice-rsp
    - `dto` command to generate feature-scoped `Dto` artifacts from typed props.
    - `entity` command to generate feature-scoped `Entity` artifacts from typed props.
    - `param` command to generate feature-scoped `Param` artifacts from typed props.
    - `request` command to generate feature-scoped `Request` artifacts from typed props.
    - `input-text` command to generate shared text field widgets and ARB keys.
    - `input-number` command to generate shared numeric text field widgets.
    - `input-dropdown` command to generate shared dropdown field widgets and ARB keys.
    - `input-password` command to generate shared password field widgets with visibility toggle and ARB keys.
    - `input-selector-list` command for list selector field generation.
    - `rm-feature` now performs feature-prefix rollback for shared exception/failure/failure_x artifacts and ARB keys.
    - `rm-feature` now supports post-hook execution and `--hook-disabled` behavior parity with other generators.
    - `cp-ui` command to duplicate UI slice flow into a new slice name, excluding generated files and applying class/file rename in copied artifacts.
    - post-hook execution now supports timeout control and clearer failure diagnostics.
- fix:
    - sequence manifest (`sequence.yaml`) is now rendered with generated variables before checkpoint weaving.
    - standalone generated Dart files are normalized to prevent leftover comma/blank-line artifacts from template weaving.
    - remove stale legacy `SequenceCode` fallback path in slice generator that could trigger unresolved bundle resolver errors.
- refactor:
    - standardize build_runner post-hook commands to `dart run build_runner build --delete-conflicting-outputs --force-jit` for Flutter 3/4 compatibility.
    - align v2 documentation tracks around explicit `slice-*` and `ui-*` generation flow plus module-scoped `di` usage.
    - remove generated `resolveEntries` contract from `ui-form` and `ui-form-dialog` for dropdown widgets; dropdown entries are now built inside field widgets.

## 1.1.0

- add:
    - enum command to scaffold enum/domain converter/localize extension artifacts and inject ARB/export entries
    - dedicated UI command surface:
        - ui-main
        - ui-dialog
        - ui-form
        - ui-form-dialog
        - ui-lsh
        - ui-lsv
        - ui-pag
        - ui-pmi
        - ui-action
        - ui-sec
    - compose-action command for logic/listener-only action composition (manual button placement)
    - compose-form-dialog command for dialog-based form composition (uses *_dialog widget as primary surface)
    - ui-form --fields support for dynamic shared field widget generation and ARB field keys
    - ui-form-dialog --fields support for form-in-dialog widget generation
- refactor:
    - di command now targets module scope by default (`fsda di <module> -a <app>`) and scans all module features (optional `-f` filter)
    - gen-ui moved to legacy wrapper with migration hint to ui-* commands
    - gen-slice no longer triggers UI generation; UI flow is separated via dedicated ui-* commands
    - ui generator operation label is now caller-driven for clearer affected-path summaries
    - template pipeline now prints transparent dependency/dev-dependency/post-hook execution plan
- fix:
    - ui_dialog template localization import now uses module placeholder instead of hardcoded finance reference
    - compose-main/compose-form/compose-pag/compose-pmi route sync now preserves existing base route builder
    - ui-form generation no longer fails when Param constructor shape/count differs; generator falls back safely
    - ui-form/ui-form-dialog shared field widgets are kept private (removed from feature barrel exports)

## 1.0.16

- refactor:
    - explicit log generator
    - snackbar extension with close action
    - in AppSection (app_ui), content renamed to child
    - position of certain elements in the UI for composition page
        - functional method above build method
        - widget methods below build method

## 1.0.15

- fix:
    - mason brick template for app bundle
    - package template for app_l10n

## 1.0.14

- fix:
    - mason brick template for main ui bundle
- refactor:
    - location of network_timeout_config.dart
- add:
    - unauthorized exception and failure in core package

## 1.0.13

- refactor:
    - rebuild ui template

## 1.0.12

- refactor:
    - rebuild template

## 1.0.11

- refactor:
    - regen lsv brick template

## 1.0.10

- refactor:
    - ui lsv brick (list->slice)

## 1.0.9

- refactor:
    - ui detail brick (error feedback)
    - ui detail bundle brick => ui main bundle brick

## 1.0.8

- gitignore to module brick

## 1.0.7

- refactor:
    - _buildPrimaryContent => _buildContent
- fix: 
    - ignore part skeleton for compose pag service
    - ignore part skeleton for compose pmi service

## 1.0.6

- fix: ignore part skeleton

## 1.0.5

- fix: module & app bundle

## 1.0.4

- fix: triple brace for bricks app & module

## 1.0.3

- refactor: dart sdk string character

## 1.0.2

- Fix: app mason brick template to use dart sdk version with string format

## 1.0.1

- Update dart sdk version: >= 3.10.7 < 4.0.0 with string format

## 1.0.0

- Initial version.
- inject dart sdk version: >= 3.10.7 < 4.0.0
