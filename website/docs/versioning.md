---
id: versioning
title: Versioning Docs
slug: /versioning
---

This documentation site is configured for multi-version docs using Docusaurus.

## Current Strategy

- current docs track main branch and are labeled next
- stable docs snapshots are stored under versioned_docs
- versions metadata is tracked in versions.json

## Create a New Docs Version

From website directory:

```bash
npm run docs:version 1.0.17
```

This will:

- snapshot current docs into versioned_docs/version-1.0.17
- register the version in versions.json
- keep current docs editable for next changes

## Publish

Docs are published automatically through GitHub Actions workflow:

- .github/workflows/docs.yml

It builds website and deploys to GitHub Pages.

## Version Switcher UX

Navbar includes docsVersionDropdown to switch between next and tagged versions.
