import 'package:flutter/material.dart';
import 'package:life_calendar/core/constants/constants.dart';
import 'package:life_calendar/core/l10n/app_localizations_extension.dart';

class EventTextField extends StatefulWidget {
  const EventTextField({
    super.key,
    this.initialText,
    required this.onChanged,
    required this.onEditingComplete,
  });

  final String? initialText;
  final Function(String text) onChanged;
  final Function(String text) onEditingComplete;

  @override
  State<EventTextField> createState() => _EventTextFieldState();
}

class _EventTextFieldState extends State<EventTextField> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _textController,
      maxLength: maxTitleLength,
      autofocus: true,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(border: UnderlineInputBorder()),
      onChanged: widget.onChanged,
      onEditingComplete: () => widget.onEditingComplete(_textController.text),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.l10n.errorEmptyField;
        }

        return null;
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
