---
id: commands-index
title: CLI Commands
---

# FSDA CLI Commands

Comprehensive documentation for all commands available in **FSDA CLI** to manage workspaces, modules, features, and application integration in an automated and structured workflow.

## Structure & Architectural Lifecycle

Commands in FSDA CLI are organized according to the architectural development lifecycle:

### 1. Workspace & Infrastructure
* **[Workspace](./workspace.md)** (`create`) — Initializes the root monorepo project along with the `fsda.yaml` configuration.
* **[Package](./package.md)** (`pkg list`, `pkg get`, `pkg add`, `pkg rm`) — Manages internal template packages and dependencies.

### 2. Core Layer & Domain Modelling (Module Level)
* **[Module](./module.md)** (`gen-module`) — Scaffolds a new module from the brick template.
* **[Feature](./feature.md)** (`gen-feature`, `rm-feature`) — Scaffolds feature layer structures (`data`, `domain`, `logic`, `ui`) and injects barrel exports and localization keys.
* **[Failure](./failure.md)** (`gen-failure`) — Injects custom exceptions, failure enums, and error localization entries.
* **[Datasource](./datasource.md)** (`ds-remote`, `ds-local`) — Generates remote and local data sources and automatically wires them into repositories.
* **[Enum](./enum.md)** (`gen-enum`, `rm-enum`) — Generates typed `Enum` definitions, JSON converters, and UI extensions.
* **[Model](./model.md)** (`gen-model`, `rm-model`) — Generates Freezed-based models (`_entity`, `_dto`, `_param`, `_request`, `_response`).
* **[Sequence](./sequence.md)** (`gen-sequence`, `rm-sequence`) — Wires complete Data-to-Domain operation flows (*Use Case*, *Repository*, *Data Source*).

### 3. State Management & Presentation (Module Level)
* **[Logic](./logic.md)** (`gen-logic`, `gen-logic-flow`) — Generates property-based or Use Case-driven state management components (`Cubit`, `Provider`, `Riverpod`, `GetX`).
* **[Input](./input.md)** (`input-*`) — Scaffolds atomic input field UI widgets (*text, number, dropdown, selector*, etc.).
* **[UI](./ui.md)** (`gen-ui`, `gen-ui-form`, `gen-ui-lsh`, `gen-ui-lsv`, `gen-ui-pag`) — Generates slice presentation components (*content, skeleton, form, list, pagination*).

### 4. Application & Integration (App Level)
* **[App](./app.md)** (`gen-app`, `configure-app`) — Generates Flutter application projects under `apps/` and configures infrastructure DI injections.
* **[App Integration](./app_integration.md)** (`reg-module`, `reg-feature`) — Registers modules and features into the target application's router and Dependency Injection setup.
* **[Compose](./compose.md)** (`compose-r`, `compose-pag`, `compose-m`, `compose-form`) — Composes final UI wrapper artifacts (*Page, Section, Sheet, Dialog*) inside the target application.

### 5. Maintenance & Build Pipeline
* **[Maintenance](./maintenance.md)** (`drb`, `l10n`, `rebuild`, `refresh`, `fix-import`) — Executes `build_runner`, `flutter gen-l10n`, dependency cleanups, and import sorting.