import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

const int freeLimit = 3;

const int maxAge = 80;
const int maxWeekNumber = 53;

DateTime minDate = DateTime(1970, 1, 1);
DateTime maxBirthDate = DateTime.now();
DateTime maxDate = DateTime(2090, 1, 1);

double weekBoxSide = 6;
double weekBoxPadding = 0.5;

final dateMaskFormatter = MaskTextInputFormatter(
  mask: '##.##.####',
  filter: {
    "#": RegExp(r'[0-9]'),
  },
  type: MaskAutoCompletionType.lazy,
);

final RegExp dateRegExp = RegExp(r'[0-3]\d\.[01]\d\.\d\d\d\d');
