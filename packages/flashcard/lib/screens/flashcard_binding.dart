import 'package:get/get.dart';

import 'flashcard_controller.dart';

class FlashcardBinding extends Bindings{
  @override
  void dependencies() {
    Get.put<FlashcardController>(FlashcardController(),);
  }

}