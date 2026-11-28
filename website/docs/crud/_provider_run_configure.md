1. Open `.fsda/run.sh` and paste the automation script below:

```bash title=".fsda/run.sh"
#!/bin/bash
set -e

fsda pkg get
fsda pkg add infra_dio

fsda apply .fsda/plans/modules/management/index.yaml
fsda apply .fsda/plans/modules/management/features/task/index.yaml
fsda apply .fsda/plans/modules/management/features/task/list.yaml
fsda apply .fsda/plans/modules/management/features/task/detail.yaml
fsda apply .fsda/plans/modules/management/features/task/create.yaml
fsda apply .fsda/plans/modules/management/features/task/update.yaml
fsda apply .fsda/plans/modules/management/features/task/status_update.yaml
fsda apply .fsda/plans/modules/management/features/task/delete.yaml

fsda rebuild -m management

fsda gen \
    -a crud_provider \
    --org com.fdelux \
    --title "CRUD Provider" \
    --org-name "Flutter Delux"

fsda configure \
    -a crud_provider

fsda reg \
    -a crud_provider \
    -m management
fsda reg \
    -a crud_provider \
    -m management \
    -f task

fsda apply .fsda/plans/apps/crud_provider.yaml

cd apps/crud_provider
dart pub add provider
cd ../../

fsda fix-import \
    -a crud_provider \
    -m management
```

2. Execute the script from the workspace root:

```bash
fsda run
```