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
    -a crud_getx \
    --org com.fdelux \
    --title "CRUD Getx" \
    --org-name "Flutter Delux"

fsda configure \
    -a crud_getx

fsda reg \
    -a crud_getx \
    -m management
fsda reg \
    -a crud_getx \
    -m management \
    -f task

fsda apply .fsda/plans/apps/crud_getx.yaml

fsda fix-import \
    -a crud_getx \
    -m management

cd modules/management
dart pub add get
cd ../../

cd apps/crud_getx
dart pub add get
cd ../../
```

2. Execute the script from the workspace root:

```bash
fsda run
```