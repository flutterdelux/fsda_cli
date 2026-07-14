import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../extensions/color_scheme_x.dart';
import '../../extensions/color_x.dart';

import '../../tokens/app_spacing.dart';
import 'app_input_field_action.dart';
import 'app_text_field.dart';

class AppColorField extends StatefulWidget {
  final Color? color;
  final String? hintText;
  final void Function(Color? color) onColorChanged;

  const AppColorField({
    super.key,
    this.color,
    this.hintText,
    required this.onColorChanged,
  });

  @override
  State<AppColorField> createState() => _AppColorFieldState();
}

class _AppColorFieldState extends State<AppColorField> {
  late final ValueNotifier<Color?> _colorNotifier;
  late final TextEditingController _controller;

  void _colorChangedListener() {
    _controller.text = _colorNotifier.value?.toHex() ?? '';
    widget.onColorChanged(_colorNotifier.value);
  }

  void _onClear() {
    _colorNotifier.value = null;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.color?.toHex());
    _colorNotifier = ValueNotifier(widget.color)
      ..addListener(_colorChangedListener);
  }

  @override
  void didUpdateWidget(covariant AppColorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      _colorNotifier.value = widget.color;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _colorNotifier
      ..removeListener(_colorChangedListener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppTextField(
      controller: _controller,
      readOnly: true,
      hintText: widget.hintText,
      prefix: ValueListenableBuilder(
        valueListenable: _colorNotifier,
        builder: (_, selectedColor, _) {
          if (selectedColor == null) {
            return DottedBorder(
              options: CircularDottedBorderOptions(
                dashPattern: [3],
                color: colorScheme.onSurfaceThin,
              ),
              child: const CircleAvatar(
                radius: 10,
                backgroundColor: Colors.transparent,
              ),
            );
          }
          return InkWell(
            onTap: _onAdd,
            child: CircleAvatar(backgroundColor: selectedColor, radius: 12),
          );
        },
      ),
      suffix: ValueListenableBuilder(
        valueListenable: _colorNotifier,
        builder: (_, selectedColor, _) {
          return AppInputFieldAction(
            hasValue: selectedColor != null,
            onClear: _onClear,
            onPressed: _onAdd,
          );
        },
      ),
    );
  }

  void _onAdd() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          ColorPicker(
            pickerColor: _colorNotifier.value ?? colorScheme.primary,
            onColorChanged: (value) => _colorNotifier.value = value,
            hexInputBar: true,
            displayThumbColor: true,
            pickerAreaHeightPercent: 0.7,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: CloseButton(),
          ),
        ],
      ),
    );
  }
}
