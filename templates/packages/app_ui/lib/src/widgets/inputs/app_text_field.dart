import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  static const _obscuringCharacter = '•';
  static const height = 56.0;

  final TextEditingController? controller;
  final String? hintText;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputAction textInputAction;
  final void Function(String value)? onSubmitted;
  final void Function(String value)? onChanged;
  final void Function()? onTap;
  final bool expands;
  final String obscuringCharacter;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final TextAlign textAlign;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.onChanged,
    this.onTap,
    this.expands = false,
    this.textCapitalization = TextCapitalization.none,
    this.obscuringCharacter = _obscuringCharacter,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TextField(
      controller: controller,
      textInputAction: textInputAction,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      onTap: onTap,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      style: textTheme.bodyLarge,
      expands: expands,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      maxLines: expands ? null : maxLines,
      minLines: expands ? null : minLines,
      textAlign: textAlign,
      textAlignVertical: expands ? TextAlignVertical.top : null,
      keyboardType: keyboardType,
      obscureText: obscureText,
      obscuringCharacter: obscuringCharacter,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      decoration: InputDecoration(
        counterText: '',
        hintText: hintText,
        prefixIcon: prefix != null
            ? Padding(padding: const EdgeInsets.only(left: 6), child: prefix)
            : null,
        suffixIcon: suffix != null
            ? Padding(padding: const EdgeInsets.only(right: 6), child: suffix)
            : null,
      ),
    );
  }
}
