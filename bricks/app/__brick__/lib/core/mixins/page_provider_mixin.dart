import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// A mixin that provides a convenient method to build a page with multiple Providers.
mixin PageProviderMixin {
  Widget buildPage({
    required List<SingleChildWidget> providers,
    required WidgetBuilder builder,
  }) {
    return MultiProvider(
      providers: providers,
      child: Builder(builder: builder),
    );
  }
}
