import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

const int freeLimit = 3;

const int maxAge = 80;
const int maxWeekNumber = 53;

int userMaxAge = maxAge;

DateTime minDate = DateTime(1970, 1, 1);
DateTime maxBirthDate = DateTime.now();
DateTime maxDate = DateTime(2090, 1, 1);

double weekBoxSide = 6;
double weekBoxPaddingX = 0.5;
double weekBoxPaddingY = 0.5;
double horPadding = weekBoxSide;
double vrtPadding = weekBoxSide;
double labelHorPadding = weekBoxSide;
double labelVrtPadding = weekBoxSide;

final dateMaskFormatter = MaskTextInputFormatter(
  mask: '##.##.####',
  filter: {
    "#": RegExp(r'[0-9]'),
  },
  type: MaskAutoCompletionType.lazy,
);
final dateFileFormat = DateFormat('dd-MM-yyyy – hh:mm');

final RegExp dateRegExp = RegExp(r'[0-3]\d\.[01]\d\.\d\d\d\d');

const String privacyPolicyUrl = 'https://doc-hosting.flycricket.io/kalendar-zhizni-v-nedeliakh-privacy-policy/03ff23a0-6fb9-42dc-b004-22eb53ed43fb/privacy';