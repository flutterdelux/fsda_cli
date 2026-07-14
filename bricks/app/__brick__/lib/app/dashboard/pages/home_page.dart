import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: UnconstrainedBox(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              AppAssets.logo,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: const Text('{{app.titleCase()}}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [],
      ),
    );
  }
}
