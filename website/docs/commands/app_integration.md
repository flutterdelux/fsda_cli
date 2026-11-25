---
id: commands-app-integration
title: App Integration
---

These commands manage the integration of standalone modules and feature slices into target applications within your FSDA workspace by generating wrapper files and injecting dependency injection, routing, localization, and error-handling configurations.

## Register a module

```
fsda reg -m <module> -a <app>

```

Scaffolds module registration wrapper files inside the target application and automatically wires the module's core configurations into the application's entry points.

### Options

* `-m`, `--module <name>`: **(Required)** Target module name under the `modules/` directory in `snake_case`.

* `-a`, `--app <name>`: **(Required)** Target application name under the `apps/` directory in `snake_case`.

### Workspace Guard

Must be executed inside an FSDA workspace root directory where `.fsda/config.yaml` is present.

### What Happens

1. **Validates Inputs & Existence**: Verifies that both `-m` and `-a` arguments are provided and checks that both `modules/<module>` and `apps/<app>` exist physically on disk.

2. **Scaffolds App Module DI Wrapper**: Creates `<app>/lib/modules/<module>/<module>_di.dart` to hold application-level dependency injection registrations for the module.

3. **Scaffolds App Module Route Wrapper**: Creates `<app>/lib/modules/<module>/<module>_route.dart` defining the module's GoRouter navigation entry point.

4. **Injects Module Localizations**: Adds `...<Module>Localizations.localizationsDelegates,` into the `localizationsDelegates` list inside `<app>/lib/app/main_app.dart`.

5. **Injects Failure Handler**: Adds type-check mapping for `<Module>Failure` into the `localizeAny` method inside `<app>/lib/core/extensions/failure_x.dart`.

6. **Injects Module DI Registration**: Injects `<Module>Di.register();` into the `initDI()` function inside `<app>/lib/core/di/di.dart`.

7. **Injects Module Base Route**: Injects `<Module>Route.base` into the `routes` array inside `<app>/lib/app/app_router.dart`.

8. **Operation Report**: Displays a terminal summary detailing generated wrapper files and modified application target files.

### Rerun Behavior

* **Idempotent Injections**: Checks if target module registration statements already exist before modifying application files (`main_app.dart`, `failure_x.dart`, `di.dart`, `app_router.dart`). Existing injections are skipped to prevent duplicates.
* **Wrapper Preservation**: Wrapper files (`<module>_di.dart` and `<module>_route.dart`) will not overwrite existing files if they have already been created, in order to protect any manual customizations that developers may have added inside the wrapper files.

### File Structure Created & Modified

Executing `fsda reg -m user -a admin_app` produces and modifies the following paths inside `apps/admin_app/`:

```
apps/admin_app/
├── lib/
│   ├── app/
│   │   ├── main_app.dart           # [Injected] UserLocalizations.localizationsDelegates
│   │   └── app_router.dart          # [Injected] UserRoute.base
│   ├── core/
│   │   ├── di/
│   │   │   └── di.dart              # [Injected] UserDi.register()
│   │   └── extensions/
│   │       └── failure_x.dart       # [Injected] UserFailure localization handling
│   └── modules/
│       └── user/
│           ├── user_di.dart        # [Created] UserDi wrapper
│           └── user_route.dart     # [Created] UserRoute wrapper

```

## Register a feature

```
fsda reg -f <feature> -m <module> -a <app>

```

Registers a specific feature into an integrated module within a target application. It inspects the feature's physical layer files, scaffolds UI directories inside the app, and injects feature-level Dependency Injection declarations and GoRouter definitions into the module wrappers.

### Options

* `-f`, `--feature <name>`: **(Required)** Target feature name under `modules/<module>/lib/src/features/` in `snake_case`.

* `-m`, `--module <name>`: **(Required)** Target module name under `modules/` in `snake_case`.

* `-a`, `--app <name>`: **(Required)** Target application name under `apps/` in `snake_case`.

### Workspace Guard

Must be executed inside an FSDA workspace root directory where `.fsda/config.yaml` is present. Requires the target module to be registered in the app (`reg -m <module> -a <app>`) beforehand so that `<module>_di.dart` and `<module>_route.dart` exist.

### What Happens

1. **Validates Inputs & Wrappers**: Ensures `-f`, `-m`, and `-a` arguments are valid and checks that the module's wrapper files (`<module>_di.dart` and `<module>_route.dart`) exist inside the target application.

2. **Scaffolds Application Feature Folders**: Creates `pages/` and `widgets/` directories for the feature under `<app>/lib/modules/<module>/features/<feature>/`.

3. **Inspects Feature Declarations**: Scans the feature directory inside the module (`data/datasources`, `domain/repositories`, `domain/usecases`, `logic/`) to detect declared components and constructor dependencies.

4. **Injects Feature DI**:

   * Adds `_<feature>Di();` call inside the `register()` method in `<module>_di.dart`.

   * Generates `static void _<feature>Di()` containing Service Locator (`sl`) registrations. Uses `registerFactoryParam` if the logic component expects non-UseCase constructor arguments, or `registerFactory` for standard UseCase injections.

5. **Injects Feature Routes**:

   * Adds route constants (`_<feature>` and `_<feature>Path`) into `<module>_route.dart`.

   * Injects `<Feature>Base` getter with a clean GoRoute template into `<module>_route.dart`.

   * Adds a navigation helper function (`to<Feature>(BuildContext context)`) into `<module>_route.dart`.

6. **Operation Report**: Displays a terminal summary detailing created directories and modified files.

### Rerun Behavior

* **Idempotent Injections**: Skips injecting duplicate method calls or route constants if the feature is already registered in the module wrappers and application router.

### File Structure Created & Modified

Executing `fsda reg -f staff -m user -a admin_app` (after module registration) produces and modifies the following paths inside `apps/admin_app/`:

```
apps/admin_app/
├── lib/
│   └── modules/
│       └── user/
│           ├── user_di.dart        # [Injected] Pemanggilan & fungsi _staffDi()
│           ├── user_route.dart     # [Injected] staffBase, konstanta path, & helper toStaff()
│           └── features/
│               └── staff/
│                   ├── pages/       # [Scaffolded]
│                   └── widgets/     # [Scaffolded]

```