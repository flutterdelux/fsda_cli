# FSDA CLI

[![codecov](https://codecov.io/github/flutterdelux/fsda_cli/graph/badge.svg)](https://codecov.io/github/flutterdelux/fsda_cli)

Feature Slice Driven Architecture CLI for workspace scaffolding and code generation.

## What's New in v2.0.0

FSDA CLI v2.0.0 introduces **3 Generation Modes** tailored to your development workflow:

1. **Imperative Mode** — Execute commands directly from your terminal for quick, on-the-fly scaffolding (`fsda gen -m <module> -f <feature>`).
2. **Declarative Mode** — Define your entire modules, features, and slice blueprints in structured YAML plans (`.fsda/plans/`) and apply them with `fsda apply`.
3. **Batch Mode** — Write, edit, and organize multiple CLI commands comfortably in `.fsda/run.sh`, then execute them sequentially in a single step using `fsda run`.

## Documentation

For detailed usage instructions and guides, please refer to the [FSDA CLI Documentation](https://flutterdelux.github.io/fsda_cli/).

## Prerequisites

Before installing FSDA CLI, make sure your environment has:

- Dart SDK (`>=3.10.7`)
- Flutter SDK

## Install Globally

```bash
dart pub global activate fsda_cli
```

Verify installation:

```bash
fsda --version
```

## Quick Workflow

Build a workspace including 1 module, 1 feature, 1 slice for popular destinations, and 1 travel app.

Follow this instruction: [Quick Workflow](https://flutterdelux.github.io/fsda_cli/docs/getting-started#quick-worflow)
