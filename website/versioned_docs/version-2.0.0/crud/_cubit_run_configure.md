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
    -a crud_cubit \
    --org com.fdelux \
    --title "CRUD Cubit" \
    --org-name "Flutter Delux"

fsda configure \
    -a crud_cubit

fsda reg \
    -a crud_cubit \
    -m management
fsda reg \
    -a crud_cubit \
    -m management \
    -f task

fsda apply .fsda/plans/apps/crud_cubit.yaml

fsda fix-import \
    -a crud_cubit \
    -m management
```

2. Execute the script from the workspace root:

```bash
fsda run
```