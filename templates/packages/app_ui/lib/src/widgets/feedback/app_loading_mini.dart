import 'package:flutter/material.dart';

class AppLoadingMini extends StatelessWidget {
  static const _size = 20.0;

  final Color? color;

  const AppLoadingMini({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: CircularProgressIndicator.adaptive(
        strokeWidth: 2.5,
        valueColor: color != null
            ? AlwaysStoppedAnimation<Color>(color!)
            : null,
      ),
    );
  }
}
