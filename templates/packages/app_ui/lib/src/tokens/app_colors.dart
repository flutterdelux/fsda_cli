import 'dart:ui';

class AppColors {
  AppColors._(); // Prevents instantiation

  /// ================= LIGHT MODE (REFINED) =================
  /// Ultra-comfortable neutral-cool palette to eliminate eye strain
  static const primaryLight = Color(0xFF00677D);
  static const onPrimaryLight = Color(0xFFFFFFFF);
  static const secondaryLight = Color(0xFF4A6267);
  static const onSecondaryLight = Color(0xFFFFFFFF);

  // Base page/scaffold background remains pure brilliant white
  static const surfaceContainerLowestLight = Color(0xFFFFFFFF);

  // Mid-layer background (Soft tint for sub-sections or inputs)
  static const surfaceContainerLowLight = Color(0xFFF0F4F5);

  // Main Card/Tiles Box background.
  static const surfaceContainerLight = Color(0xFFE6ECEF);

  // Highest contrast element above white scaffold (e.g., dialogs/popups)
  static const surfaceContainerHighestLight = Color(0xFFD2E0E4);

  static const surfaceLight = Color(0xFFF0F4F5);
  static const onSurfaceLight = Color(0xFF171C1E);

  /// ================= DARK MODE =================
  /// Deep Black Scaffold, Elevated Lighter Grey Container/Card
  static const primaryDark = Color(0xFF00B4D8);
  static const onPrimaryDark = Color(0xFF00363A);
  static const secondaryDark = Color(0xFF497D84);
  static const onSecondaryDark = Color(0xFF00363A);

  // Base page/scaffold background (Deep Slate / Pitch Black)
  static const surfaceContainerLowestDark = Color(0xFF0C1113);

  // Intermediate layer between scaffold and main card
  static const surfaceContainerLowDark = Color(0xFF131A1D);

  // Main Card / Tiles / Box background (Elevated dark grey, lighter than scaffold)
  static const surfaceContainerDark = Color(0xFF192225);

  // Top-most layer element closest to user's eye (e.g., dialogs/popups)
  static const surfaceContainerHighestDark = Color(0xFF232F34);

  static const surfaceDark = Color(0xFF192225); // Fallback surface
  static const onSurfaceDark = Color(0xFFE6E8E8);
}
