import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../extensions/color_scheme_x.dart';

class AppShimmer extends StatelessWidget {
  static const _period = Duration(milliseconds: 1500);

  final double? width;
  final double? height;
  final double radius;
  final bool shimmerEnabled;

  const AppShimmer({
    super.key,
    this.width,
    this.height,
    this.radius = 4,
    this.shimmerEnabled = true,
  });

  factory AppShimmer.circle({
    required double size,
    bool shimmerEnabled = true,
  }) {
    return AppShimmer(
      width: size,
      height: size,
      radius: size,
      shimmerEnabled: shimmerEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final skeleton = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.shimmerBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    if (!shimmerEnabled) return skeleton;

    return Shimmer.fromColors(
      baseColor: colorScheme.shimmerBase,
      highlightColor: colorScheme.shimmerHighlight,
      period: _period,
      child: skeleton,
    );
  }
}
