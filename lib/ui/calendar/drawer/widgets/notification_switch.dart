import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/core/l10n/app_localizations_extension.dart';
import 'package:life_calendar/domain/interactor/weekly_notification_interactor.dart';
import 'package:life_calendar/ui/calendar/drawer/bloc/settings_cubit.dart';

class NotificationSwitch extends StatefulWidget {
  const NotificationSwitch({super.key});

  @override
  State<NotificationSwitch> createState() => _NotificationSwitchState();
}

class _NotificationSwitchState extends State<NotificationSwitch> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsCubit>().loadSettings();
    });
  }

  Future<void> _onToggle(BuildContext context, bool value) async {
    // Capture before the async gap to avoid using context after await.
    final messenger = ScaffoldMessenger.of(context);
    final hint = context.l10n.notificationPermissionDeniedHint;

    final result = await context.read<SettingsCubit>().toggleReminder(value);

    if (result == ToggleReminderResult.permissionDenied) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(hint)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SwitchListTile.adaptive(
          secondary: const Icon(Icons.event_repeat),
          title: Text(context.l10n.notificationSwitchTitle),
          value: state.isWeeklyReminderEnabled,
          onChanged: (value) => _onToggle(context, value),
        );
      },
    );
  }
}
