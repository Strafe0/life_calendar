import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveActionMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String editLabel;
  final String deleteLabel;
  final String cancelLabel; // Needed for the iOS ActionSheet

  const AdaptiveActionMenu({
    super.key,
    required this.onEdit,
    required this.onDelete,
    required this.editLabel,
    required this.deleteLabel,
    required this.cancelLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _buildCupertinoMenu(context);
    }
    return _buildMaterialMenu(context);
  }

  // --- iOS Implementation ---
  Widget _buildCupertinoMenu(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size.square(40),
      child: Icon(
        CupertinoIcons.ellipsis_circle,
        color: Theme.of(context).colorScheme.onSurface,
        size: 24,
      ),
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  onEdit();
                },
                child: Text(editLabel),
              ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  onDelete();
                },
                child: Text(deleteLabel),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: Text(cancelLabel),
            ),
          ),
        );
      },
    );
  }

  // --- Android/Material Implementation ---
  Widget _buildMaterialMenu(BuildContext context) {
    return PopupMenuButton<int>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onSelected: (value) {
        if (value == 1) onEdit();
        if (value == 2) onDelete();
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 1, child: Text(editLabel)),
        PopupMenuItem(value: 2, child: Text(deleteLabel)),
      ],
    );
  }
}
