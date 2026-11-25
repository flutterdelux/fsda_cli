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

## Quick workflow: direct CLI

This example creates a workspace, generates a location module and destination feature, then composes a section into an app. Run commands from the workspace root unless noted otherwise.

```bash
fsda create travel_kan
cd travel_kan

fsda pkg get
fsda pkg add infra_dio infra_logging

fsda gen -m location
fsda gen -m location -f destination
fsda ds-remote \
    -m location -f destination \
    --base-path "/destinations"

fsda gen-model \
    -n destination_entity \
    -m location -f destination \
    --with-dto --l10n \
    -p "int:id" \
    -p "String:name" \
    -p "String:description" \
    -p "String:image_url" \
    -p "double:rating" \
    -p "int:review_count" \
    -p "bool:is_popular" \
    -p "DateTime:created_at::UtcDateTimeConverter" \
    -p "DateTime:updated_at::UtcDateTimeConverter"

fsda gen-sequence -m location -f destination --act get \
  --uc destination_popular_use_case -d get_destination_popular \
  --list --model destination_dto --model destination_entity
fsda gen-logic-flow -m location -f destination -s popular \
  -t r --uc destination_popular_use_case -c cubit
fsda gen-ui -m location -f destination -s popular \
  -t lsh --model destination_entity
fsda rebuild -m location

fsda gen -a travelkan --org com.fdelux --title "Travel Kan" \
  --org-name "Flutter Delux"
fsda configure -a travelkan
fsda reg -a travelkan -m location
fsda reg -a travelkan -m location -f destination
fsda compose -a travelkan -m location -f destination \
  -t r --target destination_popular_section \
  --logic-flow popular --ui popular
```

The `compose` command creates a wrapper; add that section to the desired app page yourself. It does not update routes. Use `fsda help <command>` for exact options. For example, `fsda gen -h`, `fsda reg -h`, or `fsda plan -h`.

## Quick workflow: declarative YAML

The declarative workflow stores workspace settings and plans under `.fsda/`. Scaffold an example slice plan:

```bash
fsda plan -m location -f destination -s popular --example
fsda plan -a travel_kan --example
```

The file is created at `.fsda/plans/modules/location/features/destination/popular.yaml`. Edit it to describe the generation operations, then apply it:

```bash
fsda apply .fsda/plans/modules/location/features/destination/popular.yaml
fsda rebuild -m location
fsda apply .fsda/plans/apps/travel_kan.yaml
```

A plan can include data sources, enums, models, sequences, logic, logic flows, input widgets, and UI. Feature and slice plans create missing parent module/feature structures before applying sections. An app plan (`fsda plan -a travelkan`) describes app-side `compose` artifacts; the app, module/feature registration, and source logic/UI must already exist.

See the [Declarative YAML Plans](./declarative.md) guide for schema details and execution behavior.

## Finish and verify

Review the generated operation summary and inspect generated artifacts. For a section compose, import and place the generated widget in a page, then run/analyze the app. Update the remote data source implementation with the actual endpoint behavior as needed.

Perform a manual check and make adjustments—including invoking the sections on the home page, since the generated Compose code consists of section widgets—and then test it.

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

<img src="/fsda_cli/images/travelkan.png" alt="TravelKan" width="100%" />