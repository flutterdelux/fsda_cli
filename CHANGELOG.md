## 2.0.0-dev.8

### Improved

- Stream real-time terminal output directly when executing `.fsda/run.sh` via `fsda run`.
- Improve cross-platform support on Windows by automatically detecting Git Bash executables and providing a clear error message if `bash` is unavailable.

## 2.0.0-dev.7

### Added

- Add `fsda run` command to execute workspace shell scripts located at `.fsda/run.sh`.


## 2.0.0-dev.6

### Added

- Add a declarative YAML workflow alongside direct CLI commands:
    - `fsda plan` scaffolds app, module, feature, or slice plans under `.fsda/plans/`; `--example` (`-e`) populates an example plan.
    - `fsda apply <plan.yaml>` validates and applies plans through the existing generation/composition services.
    - Plans can declare module failures; feature/slice data sources, enums, models, sequences, logic, logic flows, inputs, and UI; and app-side compose artifacts.
- Move workspace settings from root `fsda.yaml` to `.fsda/config.yaml`; workspace plans live under `.fsda/plans/`. Config uses `dart_sdk` for the Dart constraint.

### Changed

- Consolidate app/module/feature/failure generation under `fsda gen` (`-a`, `-m`, `-f`, `--failure`) and feature removal under `fsda rm -m <module> -f <feature>`.
- Consolidate module/feature registration under `fsda reg`; use `-a` and `-m` for module registration and add `-f` for feature registration.
- Replace compose-specific commands with `fsda compose` and `--type` (`m`, `r`, `pag`, `form`), `--target`, and the applicable logic/UI options.
- Consolidate per-widget `input-*` commands as `gen-input -t <type> --field <field>`; consolidate UI variants as `gen-ui -t <type>`, with repeatable `--field` options for forms.
- Update generation arguments: `gen-model`/`rm-model` take `-n <name>`; `gen-sequence` takes `--act` and repeatable `--model` instead of a positional action and `--models` list.
- App names now use strict `snake_case`; the app display-name option is `--title` (replacing `--name`).
- Since v2.0.0-dev.1, the CLI command interface has been regrouped; update scripts using the earlier standalone `gen-app`, `gen-module`, `gen-feature`, `gen-failure`, `reg-module`, `reg-feature`, `compose-*`, `input-*`, and variant-specific `gen-ui-*` commands.


## 2.0.0-dev.5

### Fix

- Pin compatible version constraints for code-generation dependencies (`freezed_annotation`, `json_annotation`, `build_runner`, `freezed`, and `json_serializable`) in `ModuleService` to prevent version resolution conflicts when generating new modules.


## 2.0.0-dev.4

### Refactor

- Centralize `ScrollConfiguration` globally in `MainApp` with `scrollbars: false` and multi-device drag support, removing redundant per-widget `ScrollConfiguration` wrappers from UI templates.


## 2.0.0-dev.3

### Fix

- Allow top-level CLI flags such as `--version`, `-h`, and `--help` to bypass unknown-command validation in `main`.


## 2.0.0-dev.2

### Fix

- Include `lib/infrastructure/templates/` files in the published package archive by scoping root `/templates/` in `.pubignore`.


## 2.0.0-dev.1

### Breaking changes

- The CLI command surface has been redesigned; v1.1.0 scripts are not fully compatible:
    - `gen-slice` and `regen-feature` have been removed. Generate logic with `gen-logic` / `gen-logic-flow`, data-to-domain operations with `gen-sequence`, and presentation separately with `gen-ui*`.
    - The v1 dedicated `ui-*` commands and generic `gen-ui -u <ui_code>` interface have been replaced by `gen-ui`, `gen-ui-form`, `gen-ui-lsh`, `gen-ui-lsv`, and `gen-ui-pag`; the old UI variants do not all have one-to-one replacements. Form fields now use repeatable `--field "input_type:value_type:field_name[:default]"` options and require a model; update old `--fields` invocations.
    - The former `compose-main`, `compose-pmi`, `compose-sec`, `compose-action`, and `compose-form-dialog` modes are no longer available. Use `compose-r`, `compose-m`, `compose-pag`, or `compose-form` with the new `--logic-flow`, `--ui` / `--logic`, and `--target` arguments as applicable.
    - Compose commands now generate the target app artifact only; they do not synchronize module routes. Add or update route wiring in the app yourself.
    - `reg` is replaced by `reg-module`, with `reg-feature` for feature registration. The old `di` and `rm-reg` commands are no longer registered.
    - Package commands moved from `list-pckg` / `add-pckg` to `pkg list` / `pkg add`; `pkg get` replaces the old workspace `configure` sync command, and `pkg rm` is also available.

### Added

- Added model generation and removal with `gen-model` / `rm-model` for entity, DTO, param, request, and response types. Generation supports paired entity+DTO and param+request output, automatic import resolution, barrel exports, and optional entity localization.
- Added `gen-sequence` / `rm-sequence` to create or remove a complete use-case, repository, and data-source operation, including method wiring and localization updates.
- Added separate `gen-logic` and `gen-logic-flow` generators, with state-control options for supported state-management approaches.
- Added dedicated `ds-remote`, `ds-local`, `gen-failure`, and `input-*` generators for data sources, failure contracts, and reusable input widgets with type imports and localization entries.
- Added module/app-scoped maintenance commands: `drb`, `l10n`, `rebuild`, `refresh`, and `fix-import`.
- Expanded bundled package templates with responsive helpers and breakpoints, `NetworkFile` support, additional UI components, and a Dio authentication interceptor.

### Changed

- Workspace package management now synchronizes selected bundled packages with `fsda.yaml` and the workspace package directory through `pkg` commands.
- Generation commands use layer-specific inputs and validate names, required models, and target artifacts before writing; generated model/UI artifacts also resolve imports and update exports/localization where applicable.


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
