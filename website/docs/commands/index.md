---
id: commands-index
title: CLI Commands
---

# FSDA CLI Commands

Comprehensive documentation for all commands available in **FSDA CLI** to manage workspaces, modules, features, and application integration in an automated and structured workflow.

## Structure & Architectural Lifecycle

Commands in FSDA CLI are organized according to the architectural development lifecycle:

### 1. Workspace & Infrastructure
* **[Workspace](./workspace.md)** (`create`) — Initializes the root monorepo project with `.fsda/config.yaml` and declarative plan directories.
* **[Package](./package.md)** (`pkg list`, `pkg get`, `pkg add`, `pkg rm`) — Manages internal template packages and dependencies.

### 2. Core Layer & Domain Modelling (Module Level)
* **[Module](./module.md)** (`gen -m`) — Scaffolds a new module from the brick template.
* **[Feature](./feature.md)** (`gen -m -f`, `rm -m -f`) — Scaffolds/removes feature layer structures and updates exports/localization.
* **[Failure](./failure.md)** (`gen -m --failure`) — Injects custom exceptions, failure enums, and error localization entries.
* **[Datasource](./datasource.md)** (`ds-remote`, `ds-local`) — Generates remote and local data sources and automatically wires them into repositories.
* **[Enum](./enum.md)** (`gen-enum`, `rm-enum`) — Generates typed `Enum` definitions, JSON converters, and UI extensions.
* **[Model](./model.md)** (`gen-model`, `rm-model`) — Generates Freezed-based models (`_entity`, `_dto`, `_param`, `_request`, `_response`).
* **[Sequence](./sequence.md)** (`gen-sequence`, `rm-sequence`) — Wires complete Data-to-Domain operation flows (*Use Case*, *Repository*, *Data Source*).

### 3. State Management & Presentation (Module Level)
* **[Logic](./logic.md)** (`gen-logic`, `gen-logic-flow`) — Generates property-based or Use Case-driven state management components (`Cubit`, `Provider`, `Riverpod`, `GetX`).
* **[Input](./input.md)** (`gen-input`) — Scaffolds atomic input field UI widgets (*text, number, dropdown, selector*, etc.).
* **[UI](./ui.md)** (`gen-ui`) — Generates standard, form, list, or pagination presentation components.

### 4. Application & Integration (App Level)
* **[App](./app.md)** (`gen -a`, `configure -a`) — Generates Flutter application projects under `apps/` and configures infrastructure DI injections.
* **[App Integration](./app_integration.md)** (`reg -a -m [-f]`) — Registers modules and features into the target application's router and Dependency Injection setup.
* **[Compose](./compose.md)** (`compose`) — Composes UI wrapper artifacts (*Page, Section, Sheet, Dialog*) inside the target application.

### Declarative workflow

* **[Declarative YAML plans](../declarative.md)** (`plan`, `apply`) — Describe module, feature, slice, or app composition work in YAML and apply it through the same generators used by CLI commands.

### 5. Maintenance & Build Pipeline
* **[Maintenance](./maintenance.md)** (`drb`, `l10n`, `rebuild`, `refresh`, `fix-import`) — Executes `build_runner`, `flutter gen-l10n`, dependency cleanups, and import sorting.