import 'package:flutter/material.dart';

import '../../tokens/app_radius.dart';

class AppBorderTheme {
  static OutlinedBorder get shape => const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
  );
}
