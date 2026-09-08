## 1.1.0

- add:
    - gen-enum command to scaffold enum/domain converter/localize extension artifacts and inject ARB/export entries
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
