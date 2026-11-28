---
id: getting-started
title: Getting Started
slug: /getting-started
---

## Prerequisites

Install the Dart SDK and Flutter SDK required by your projects, then install FSDA CLI:

```bash
dart pub global activate fsda_cli
fsda --version
```

## 1. Initialize workspace

Both workflows start by creating a new FSDA workspace via the CLI and opening it in your IDE (such as VS Code):

```bash
fsda create travelio
cd travelio
code .
```

Once opened in your IDE, you will find the `.fsda/` directory containing `config.yaml`, `plans/`, and `run.sh`. Choose one of the two workflows below to build your feature and app.

---

## 2. Choose your workflow

<Tabs groupId="workflow-type">
  <TabItem value="cli" label="CLI Script (fsda run)" default>

This workflow automates imperative CLI commands inside `.fsda/run.sh`.

1. Open `.fsda/run.sh` in your IDE and paste the following commands below `set -e`:

```bash title=".fsda/run.sh"
#!/bin/bash
set -e

fsda pkg get
fsda pkg add infra_dio

fsda gen -m location
fsda gen \
    -m location \
    -f destination

fsda ds-remote \
    --base-path "/destinations" \
    -m location \
    -f destination

fsda gen-model \
    -n destination_entity \
    --with-dto \
    --l10n \
    -p "int:id" \
    -p "String:name" \
    -p "String:description" \
    -p "String:image_url" \
    -p "double:rating" \
    -p "int:review_count" \
    -p "bool:is_popular" \
    -p "DateTime:created_at::UtcDateTimeConverter" \
    -p "DateTime:updated_at::UtcDateTimeConverter" \
    -m location \
    -f destination

fsda gen-model \
    -n destination_popular_response \
    -p "List<DestinationDto>?:data" \
    -p "String:message" \
    -m location \
    -f destination

fsda gen-sequence \
    --uc destination_popular_use_case \
    -d get_destination_popular \
    --act get \
    --list \
    --model destination_popular_response \
    --model destination_dto \
    --model destination_entity \
    -m location \
    -f destination

fsda gen-logic-flow \
    -t r \
    --uc destination_popular_use_case \
    -m location \
    -f destination \
    -s popular

fsda gen-ui \
    -t lsh \
    --model destination_entity \
    -m location \
    -f destination \
    -s popular

fsda rebuild -m location

fsda gen \
    -a travelio \
    --org com.fdelux \
    --title "Travelio Cubit" \
    --org-name "Flutter Delux"

fsda configure \
    -a travelio

fsda reg \
    -a travelio \
    -m location
fsda reg \
    -a travelio \
    -m location \
    -f destination

fsda compose \
    -t r \
    -a travelio \
    -m location \
    -f destination \
    --logic-flow popular \
    --ui popular \
    --target destination_popular_section

fsda fix-import \
    -a travelio \
    -m location
```

2. Execute the script from the workspace root:

```bash
fsda run
```

  </TabItem>
  <TabItem value="declarative" label="Declarative YAML">

This workflow combines CLI scaffolding commands with declarative YAML plan files stored under `.fsda/plans/`.

1. **Install dependencies:**

```bash
fsda pkg get
fsda pkg add infra_dio
```

2. **Scaffold and apply the module plan:**

```bash
fsda plan -m location --example
```

Edit `.fsda/plans/modules/location/index.yaml` manually or paste the configuration below, then apply it:

```yaml title=".fsda/plans/modules/location/index.yaml"
module: location

failure:
  # - name: destination_invalid_coordinate
  #   message: Destination coordinate is invalid.
```

```bash
fsda apply .fsda/plans/modules/location/index.yaml
```

3. **Scaffold and apply the feature slice plan:**

```bash
fsda plan -m location -f destination -s popular --example
```

Edit `.fsda/plans/modules/location/features/destination/popular.yaml` manually or paste the configuration below, then apply it and rebuild the module:

```yaml title=".fsda/plans/modules/location/features/destination/popular.yaml"
module: location
feature: destination
slice: popular

ds:
  remote:
    base-path: "/destinations"

model:
  - name: destination_entity
    with-dto: true
    l10n: true
    prop:
      - "int:id"
      - "String:name"
      - "String:description"
      - "String:image_url"
      - "double:rating"
      - "int:review_count"
      - "bool:is_popular"
      - "DateTime:created_at::UtcDateTimeConverter"
      - "DateTime:updated_at::UtcDateTimeConverter"
  - name: destination_popular_response
    prop:
      - "String:message"
      - "List<DestinationDto>?:data"

sequence:
  - uc: destination_popular_use_case
    act: get
    method: get_destination_popular
    flow: async
    ds: remote
    list: true
    model:
      - destination_dto
      - destination_entity
      - destination_popular_response

logic-flow:
  - slice: popular
    type: r
    uc: destination_popular_use_case
    control: cubit

ui:
  - slice: popular
    type: lsh
    model: destination_entity
```

```bash
fsda apply .fsda/plans/modules/location/features/destination/popular.yaml
fsda rebuild -m location
```

4. **Generate, configure, and register the app:**

```bash
fsda gen \
    -a travelio \
    --org com.fdelux \
    --title "Travelio Cubit" \
    --org-name "Flutter Delux"
fsda configure -a travelio

fsda reg -a travelio -m location
fsda reg -a travelio -m location -f destination
```

5. **Scaffold and apply the app composition plan:**

```bash
fsda plan -a travelio --example
```

Edit `.fsda/plans/apps/travelio.yaml` manually or paste the configuration below, then apply it and organize imports:

```yaml title=".fsda/plans/apps/travelio.yaml"
app: travelio

compose:
  - module: location
    feature: destination
    type: r
    target: destination_popular_section
    logic-flow: popular
    ui: popular
```

```bash
fsda apply .fsda/plans/apps/travelio.yaml
fsda fix-import -a travelio -m location
```

> Feature and slice plans automatically create missing parent module/feature structures before applying sections. An app plan (`fsda plan -a travelio`) describes app-side `compose` artifacts; the app, module/feature registration, and source logic/UI must already exist. See the [Declarative YAML Plans](./declarative.md) guide for schema details.

  </TabItem>
</Tabs>

---

## 3. Finish and verify

Regardless of which workflow you used, review the generated operation summary and inspect the generated artifacts.

The `compose` command creates a wrapper section widget without updating app routes. Import and place the generated widget in your page, then update the remote data source implementation with the actual endpoint behavior as needed.

```dart title="home_page.dart" {2,7}
...
import '../../../modules/location/features/destination/widgets/destination_popular_section.dart';
...
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          const DestinationPopularSection(),
        ],
      ),
...
```

```dart title="destination_remote_data_source_impl.dart" {5}
import 'package:app_core/app_core.dart';
...
  @override
  Future<List<DestinationDto>> getDestinationPopular() async {
    final path = '$_basePath/popular';
    ...
  }
...
```

Finally, run or analyze the app to verify everything works as expected.

<img src="/fsda_cli/images/travelkan.png" alt="TravelKan" width="100%" />
