import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/core/constants/constants.dart';
import 'package:life_calendar/core/extensions/string/string_extension.dart';
import 'package:life_calendar/core/l10n/app_localizations_extension.dart';
import 'package:life_calendar/core/utils/local_date_format_utils.dart';
import 'package:life_calendar/ui/core/widgets/date_text_field.dart';
import 'package:life_calendar/ui/core/widgets/lifespan_text_field.dart';
import 'package:life_calendar/ui/registration/bloc/registration_cubit.dart';

class RegistrationFormBody extends StatefulWidget {
  const RegistrationFormBody({super.key, required this.formKey});

  final GlobalKey<FormState> formKey;

  @override
  State<RegistrationFormBody> createState() => _RegistrationFormBodyState();
}

class _RegistrationFormBodyState extends State<RegistrationFormBody> {
  bool _isLoading = false;
  final _lifeSpanTextController = TextEditingController();
  DateTime? _birthdate;

  @override
  Widget build(BuildContext context) {
    // Scrolls when the space is too short (a tablet in landscape with errors
    // under the fields); otherwise it fills the space as before.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const Spacer(),
                DateTextField(
                  firstDate: firstAvailableDate,
                  lastDate: DateTime.now(),
                  fieldLabelText: context.l10n.enterBirthdate,
                  errorFormatText: context.l10n.dateFormatError,
                  onChanged: (value) {
                    final locale = Localizations.localeOf(context);

                    _birthdate = value.toDateTime(
                      locale: locale.toString(),
                      pattern: getLocalDateFormat(locale).pattern,
                    );
                  },
                ),
                const SizedBox(height: 16),
                LifeSpanTextField(controller: _lifeSpanTextController),
                const Spacer(),
                OutlinedButton(
                  onPressed: () async {
                    if (_isLoading) return;
                    setState(() => _isLoading = true);

                    final form = widget.formKey.currentState;
                    if (form != null) {
                      form.save();
                      final enteredDataIsValid = form.validate();
                      if (enteredDataIsValid) {
                        final lifeSpan = int.tryParse(
                          _lifeSpanTextController.text,
                        );
                        if (_birthdate != null && lifeSpan != null) {
                          await context.read<RegistrationCubit>().register(
                            birthday: _birthdate!,
                            lifeSpan: lifeSpan,
                          );
                        }
                      }
                    }

                    setState(() => _isLoading = false);
                  },
                  child: Text(context.l10n.ready),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _lifeSpanTextController.dispose();
    super.dispose();
  }
}
