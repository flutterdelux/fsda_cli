import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A mixin that provides a convenient method to build a page with multiple BlocProviders.
/// This mixin can be used in any page that requires multiple BlocProviders to manage its state.
mixin PageProviderMixin {
  Widget buildPage({
    required List<BlocProvider> providers,
    required List<BlocListener> listeners,
    required WidgetBuilder builder,
  }) {
    return MultiBlocProvider(
      providers: providers,
      child: listeners.isNotEmpty
          ? MultiBlocListener(
              listeners: listeners,
              child: Builder(builder: builder),
            )
          : Builder(builder: builder),
    );
  }
}
