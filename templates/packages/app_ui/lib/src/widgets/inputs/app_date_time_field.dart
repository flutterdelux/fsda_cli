import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app_ui.dart';
import 'app_input_field_action.dart';

class AppDateTimeField extends StatefulWidget {
  final DateTime? dateTime;
  final String? hintText;
  final void Function(DateTime? dateTime) onDateTimeChanged;
  final bool includeTime;

  /// Default: `DateFormat('yyyy/MM/dd HH:mm')`
  final DateFormat? dateFormat;

  const AppDateTimeField({
    super.key,
    this.dateTime,
    this.hintText,
    required this.onDateTimeChanged,
    this.includeTime = true,
    this.dateFormat,
  });

  @override
  State<AppDateTimeField> createState() => _AppDateTimeFieldState();
}

class _AppDateTimeFieldState extends State<AppDateTimeField> {
  static final _defaultDateTimeFormat = DateFormat('yyyy/MM/dd HH:mm');
  static final _defaultDateFormat = DateFormat('yyyy/MM/dd');

  late final TextEditingController _controller;
  late final ValueNotifier<DateTime?> _dateTimeNotifier;

  void _onClear() {
    _dateTimeNotifier.value = null;
  }

  void _dateTimeListener() {
    final dateTime = _dateTimeNotifier.value;
    if (dateTime != null) {
      _controller.text = _dateFormat.format(dateTime);
    } else {
      _controller.text = '';
    }
    widget.onDateTimeChanged(_dateTimeNotifier.value);
  }

  DateFormat get _dateFormat =>
      widget.dateFormat ??
      (widget.includeTime ? _defaultDateTimeFormat : _defaultDateFormat);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.dateTime != null ? _dateFormat.format(widget.dateTime!) : '',
    );
    _dateTimeNotifier = ValueNotifier(widget.dateTime)
      ..addListener(_dateTimeListener);
  }

  @override
  void didUpdateWidget(covariant AppDateTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dateTime != widget.dateTime ||
        oldWidget.includeTime != widget.includeTime) {
      _dateTimeNotifier.value = widget.dateTime;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _dateTimeNotifier
      ..removeListener(_dateTimeListener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppTextField(
      controller: _controller,
      readOnly: true,
      prefix: ValueListenableBuilder(
        valueListenable: _dateTimeNotifier,
        builder: (_, selectedDateTime, _) {
          return IconButton(
            icon: Icon(
              Icons.event,
              color: selectedDateTime == null
                  ? colorScheme.onSurfaceThin
                  : null,
            ),
            onPressed: selectedDateTime == null ? null : _onAdd,
          );
        },
      ),
      suffix: ValueListenableBuilder(
        valueListenable: _dateTimeNotifier,
        builder: (_, selectedDateTime, _) {
          return AppInputFieldAction(
            hasValue: selectedDateTime != null,
            onClear: _onClear,
            onPressed: _onAdd,
          );
        },
      ),
    );
  }

  Future<void> _onAdd() async {
    final now = DateTime.now();
    final firstDate = DateTime(1990);
    final lastDate = DateTime(now.year + 1, now.month, now.day + 1);

    final pickedDate = await showDatePicker(
      context: context,
      currentDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (pickedDate == null) return;

    if (!widget.includeTime) {
      _dateTimeNotifier.value = pickedDate;
      return;
    }

    if (!mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    _dateTimeNotifier.value = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }
}
