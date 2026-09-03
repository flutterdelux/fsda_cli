---
id: commands-index
title: Commands
slug: /commands
---

FSDA CLI commands are grouped by responsibility.

- Workspace and package setup
- Generation and regeneration
- Composition
- Maintenance and cleanup

## Command Catalog

| Command | Purpose |
| --- | --- |
| fsda create `<workspace_name>` | Create a new FSDA workspace |
| fsda configure | Sync workspace packages from fsda.yaml |
| fsda configure-app `<app>` | Sync app-level package dependencies |
| fsda list-pckg | List available package templates |
| fsda add-pckg `<name>` | Add package template into workspace/packages |
| fsda gen-app `<app>` | Generate app scaffold |
| fsda gen-module `<module>` | Generate module scaffold |
| fsda gen-feature `<feature>` -m `<module>` [--ds `<datasource_mode>`] | Generate feature baseline |
| fsda regen-feature `<feature>` -m `<module>` [--ds `<datasource_mode>`] | Regenerate missing feature baseline files |
| fsda gen-slice `<slice>` -f `<feature>` -m `<module>` -s `<sequence_code>` [-d `<method>`] [-u `<ui_code>`]... [--strict] | Generate and weave slice |
| fsda gen-ui `<slice>` -f `<feature>` -m `<module>` -u `<ui_code>` [--strict] | Generate UI template and inject manifests |
| fsda reg `<module>` -a `<app>` [--strict] | Register module wrapper into app |
| fsda di `<feature>` -m `<module>` -a `<app>` [--strict] | Sync feature DI registrations into app module DI |
| fsda rm-reg `<module>` -a `<app>` | Remove module registration from app |
| fsda compose-main `<slice>` -f `<feature>` -m `<module>` -a `<app>` -p `<target_page>` [--strict] | Compose as main page flow |
| fsda compose-form `<slice>` -f `<feature>` -m `<module>` -a `<app>` -p `<target_page>` [--strict] | Compose as form page flow |
| fsda compose-pag `<slice>` -f `<feature>` -m `<module>` -a `<app>` -p `<target_page>` [--strict] | Compose as pagination page flow |
| fsda compose-pmi `<slice>` -f `<feature>` -m `<module>` -a `<app>` -p `<target_page>` [--strict] | Inject popup menu item flow |
| fsda compose-sec `<slice>` -f `<feature>` -m `<module>` -a `<app>` -p `<target_page>` [--strict] | Inject section flow |
| fsda fix-import [-m `<module>`] [-a `<app>`] | Run import/order cleanup |

Use the sidebar pages for grouped details and examples.
