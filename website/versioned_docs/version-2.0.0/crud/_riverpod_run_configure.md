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
    -a crud_riverpod \
    --org com.fdelux \
    --title "CRUD Riverpod" \
    --org-name "Flutter Delux"

fsda configure \
    -a crud_riverpod

fsda reg \
    -a crud_riverpod \
    -m management
fsda reg \
    -a crud_riverpod \
    -m management \
    -f task

fsda apply .fsda/plans/apps/crud_riverpod.yaml

cd modules/management
dart pub add riverpod
cd ../../

cd apps/crud_riverpod
dart pub add flutter_riverpod
cd ../../

fsda fix-import \
    -a crud_riverpod \
    -m management
```

2. Execute the script from the workspace root:

```bash
fsda run
```