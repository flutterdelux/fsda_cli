import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../../extensions/color_scheme_x.dart';
import '../feedback/app_shimmer.dart';

class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final double? ratio;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final image = ExtendedImage.network(
      url,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      shape: shape,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      loadStateChanged: (state) => _handleLoadState(state, colorScheme),
    );

    if (ratio != null) {
      return AspectRatio(aspectRatio: ratio!, child: image);
    }

    return image;
  }

  Widget? _handleLoadState(ExtendedImageState state, ColorScheme colorScheme) {
    return switch (state.extendedImageLoadState) {
      LoadState.loading => AppShimmer(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        radius: borderRadius?.topLeft.x ?? 0,
      ),
      LoadState.completed => null,
      LoadState.failed => Container(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: colorScheme.onSurfaceMedium,
          ),
        ),
      ),
    };
  }
}
