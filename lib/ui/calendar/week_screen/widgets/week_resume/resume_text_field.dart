import 'package:flutter/material.dart';

class ResumeTextField extends StatefulWidget {
  const ResumeTextField({
    super.key,
    required this.initialText,
    required this.onEditingComplete,
  });

  final String initialText;
  final Function(String text) onEditingComplete;

  @override
  State<ResumeTextField> createState() => _ResumeTextFieldState();
}

class _ResumeTextFieldState extends State<ResumeTextField> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      expands: true,
      maxLines: null,
      autofocus: true,
      textAlignVertical: TextAlignVertical.top,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onEditingComplete: () => widget.onEditingComplete(_textController.text),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
