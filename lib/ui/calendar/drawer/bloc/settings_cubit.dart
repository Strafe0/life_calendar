import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/data/repositories/settings_repository/settings_repository.dart';
import 'package:life_calendar/domain/interactor/weekly_notification_interactor.dart';

// Simple settings state
class SettingsState extends Equatable {
  final bool isWeeklyReminderEnabled;

  const SettingsState({required this.isWeeklyReminderEnabled});

  @override
  List<Object?> get props => [isWeeklyReminderEnabled];
}

class SettingsCubit extends Cubit<SettingsState> {
  final WeeklyNotificationInteractor _interactor;
  final SettingsRepository _settingsRepository;

  SettingsCubit(this._interactor, this._settingsRepository)
    : super(const SettingsState(isWeeklyReminderEnabled: false));

  /// Loads the initial toggle state when the screen is opened
  Future<void> loadSettings() async {
    final isEnabled = await _settingsRepository.isWeeklyReminderEnabled();
    emit(SettingsState(isWeeklyReminderEnabled: isEnabled));
  }

  /// User toggled the switch. Returns the outcome so the UI can react
  /// (e.g. show a hint when notification permission was denied).
  // ignore: avoid_positional_boolean_parameters
  Future<ToggleReminderResult> toggleReminder(bool value) async {
    emit(SettingsState(isWeeklyReminderEnabled: value));

    final result = await _interactor.toggleNotification(isEnabled: value);

    // Revert the switch if it couldn't actually be enabled.
    if (result == ToggleReminderResult.permissionDenied ||
        result == ToggleReminderResult.error) {
      emit(SettingsState(isWeeklyReminderEnabled: !value));
    }

    return result;
  }
}
