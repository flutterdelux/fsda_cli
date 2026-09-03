---
id: workflow
title: Workflow
slug: /workflow
---

```bash
fsda create fsda_base
cd fsda_base
fsda configure
fsda list-pckg
fsda add-pckg app_core
fsda add-pckg infra_dio
fsda gen-app demo_app
fsda configure-app demo_app
fsda gen-module finance
fsda gen-feature wallet -m finance --ds remote
fsda gen-slice detail -f wallet -m finance -s Rp -u main
fsda reg finance -a demo_app
fsda di wallet -m finance -a demo_app
fsda compose-main detail -f wallet -m finance -a demo_app -p wallet_detail_page
fsda fix-import -a demo_app
```
