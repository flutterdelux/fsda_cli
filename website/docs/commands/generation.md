---
id: commands-generation
title: Generation Commands
---

## gen-app

```bash
fsda gen-app `<app>`
```

Generates a Flutter app under apps/`<app>`.

## gen-module

```bash
fsda gen-module `<module>`
```

Generates a module under modules/`<module>`.

## gen-feature

```bash
fsda gen-feature `<feature>` -m `<module>` [--ds `<datasource_mode>`]
```

Generates feature baseline files under module features.

Supported datasource modes:

- both
- remote
- local

## regen-feature

```bash
fsda regen-feature `<feature>` -m `<module>` [--ds `<datasource_mode>`]
```

Regenerates only missing baseline files without overwriting existing files.

## gen-slice

```bash
fsda gen-slice `<slice>` -f `<feature>` -m `<module>` -s `<sequence_code>` [-d `<method>`] [-u `<ui_code>`]... [--strict]
```

Generates slice files and weaves sequence checkpoint code.

Supported sequence codes:

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

Optional UI codes can be supplied via -u.

## gen-ui

```bash
fsda gen-ui `<slice>` -f `<feature>` -m `<module>` -u `<ui_code>` [--strict]
```

Generates a UI template for the slice and injects export/ARB manifests.

Supported UI codes:

- main
- dialog
- form
- lsh
- lsv
- pag
- pmi
- sec
