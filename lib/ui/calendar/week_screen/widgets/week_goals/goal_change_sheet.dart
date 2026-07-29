import 'package:flutter/material.dart';
import 'package:life_calendar/core/constants/constants.dart';
import 'package:life_calendar/core/l10n/app_localizations_extension.dart';

class GoalChangeSheet extends StatefulWidget {
  const GoalChangeSheet({super.key, required this.onSubmit, this.initialText});

  final String? initialText;
  final void Function(String) onSubmit;

  @override
  State<GoalChangeSheet> createState() => _GoalChangeSheetState();
}

class _GoalChangeSheetState extends State<GoalChangeSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _textController,
            maxLength: maxTitleLength,
            autofocus: true,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(border: UnderlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.errorEmptyField;
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              final isValid = _formKey.currentState?.validate() ?? false;

              final title = _textController.text;
              if (isValid && title.isNotEmpty) {
                widget.onSubmit(title);
              }
            },
            child: Text(context.l10n.ready),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
