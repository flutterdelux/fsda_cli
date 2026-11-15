---
id: getting-started
title: Getting Started
slug: /getting-started
---

## Prerequisites

Before installing FSDA CLI, make sure your environment has:

- Dart SDK
- Flutter SDK

## Install Globally

```bash
dart pub global activate fsda_cli
```

Verify installation:

```bash
fsda --version
```

## Quick Worflow

Build worskpace include 1 module, 1 feature, 1 slice for popular destination and 1 travel app.

If you want to stop the command sequence immediately in the event of a failure midway through the chain also track log output, you can add the following command after entering the workspace directory. (after `cd travel_kan`)

```bash
set -e; exec > >(tee -a travel_kan_workflow.log) 2>&1
```

Use chain worflow command below to your terminal.

```bash
fsda create travel_kan
cd travel_kan

set -e; exec > >(tee -a travel_kan_workflow.log) 2>&1

fsda pkg get
fsda pkg add infra_dio infra_shared_preferences infra_logging

fsda gen-module location

fsda gen-feature destination -m location
fsda ds-remote "/destinations" \
    -m location -f destination
fsda gen-model destination_entity \
    -m location -f destination \
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
    -p "DateTime:updated_at::UtcDateTimeConverter" 

fsda gen-sequence get \
    -m location -f destination \
    --uc destination_popular_use_case \
    -d get_destination_popular \
    --list \
    --models destination_dto,destination_entity
fsda gen-logic-flow r \
    -m location -f destination -s popular \
    -c cubit \
    --uc destination_popular_use_case
fsda gen-ui-lsh \
    -m location -f destination -s popular \
    --model destination_entity

fsda rebuild -m location
fsda fix-import -m location

fsda gen-app travelkan \
    --org com.fdelux \
    --name "Travel Kan" \
    --org-name "Flutter Delux"
fsda configure-app travelkan
fsda reg-module -a travelkan -m location
fsda reg-feature -a travelkan -m location -f destination

fsda compose-r \
    -a travelkan \
    -m location -f destination --logic-flow popular --ui popular \
    -t destination_popular_section
```

After that, perform a manual check and make adjustments—including invoking the sections on the home page, since the generated Compose code consists of section widgets—and then test it.

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
