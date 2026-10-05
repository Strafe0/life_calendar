import 'package:image_picker/image_picker.dart';

abstract interface class ImagePickerService {
  Future<({XFile? file, bool hasError})> pickImage();
}
