import 'package:flutter/material.dart';

Future<String?> textDialog(BuildContext context, {
  required String title,
  String? initialText,
}) async {
  final TextEditingController textController = TextEditingController();
  bool validate = true;

  if (initialText != null) {
    textController.text = initialText;
  }

  return await showDialog<String>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              controller: textController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Заполните поле',
                errorText: validate ? null : 'Поле не может быть пустым',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    validate = textController.text.isNotEmpty;
                  });
                  if (validate) {
                    Navigator.pop(context, textController.text);
                  }
                },
                child: const Text('Ок'),
              ),
            ],
          );
        },
      );
    },
  );
}