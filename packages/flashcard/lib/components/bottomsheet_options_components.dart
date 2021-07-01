import 'package:flashcard/components/components.dart';
import 'package:flashcard/screens/flashcard_controller.dart';
import 'package:flashcard/utils/client_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class BottomSheetOptionsComponent extends StatelessWidget {
  BottomSheetController controllerBottom =
  Get.put<BottomSheetController>(BottomSheetController());
  FlashcardController flashcardController = Get.find();
  Widget topBottomSheet() {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            width: 60,
            height: 5,
            decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10)),
          ),
          SizedBox(height: 10),
          Container(
            child: Text(
              "Tùy chọn",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bodyBottomSheet() {
    return GetBuilder<BottomSheetController>(
      builder: (controller) {
        return Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ItemButtonCustom(
                      title: Icon(
                        FontAwesomeIcons.random,
                        size: 20,
                        color:
                            controller.isRandomCard.value ? Colors.amber : null,
                      ),
                      onTap: () {
                        controller.changeIsRandomCard();
                        flashcardController.shuffleDataCard(
                          controller.isRandomCard.value,
                        );
                      },
                    ),
                    ItemButtonCustom(
                      title: Icon(
                        FontAwesomeIcons.volumeUp,
                        size: 20,
                        color:
                            controller.isPronounce.value ? Colors.amber : null,
                      ),
                      onTap: () {
                        controller.changeIsPronounce();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              "Hỏi nhanh thẻ ghi nhớ",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            "Sắp xếp thẻ ghi nhớ của bạn thành hai bộ bằng cách vuốt sang phải nếu bạn biết và sang trái nếu không!",
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Switch(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: controller.isSwitch.value,
                        onChanged: (value) {
                          controller.changeSwitch();
                          flashcardController.changeIsShowStatusCard(value);
                        },
                        activeTrackColor: Colors.amber,
                        activeColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget bottomBottomSheet() {
    return GetBuilder<BottomSheetController>(
      builder: (controller) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 30),
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  "Thiết lập thẻ ghi nhớ",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  "Mặt trước",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      controller.changeIsWordSelect(true);
                      flashcardController.changeIsShowShowWordOnFontCard(true);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: controller.isWordSelect.value
                                ? Colors.amber
                                : Colors.black12,
                            width: 2),
                      ),
                      child: Text(
                        "Thuật ngữ",
                        style: TextStyle(
                          color: !controller.isWordSelect.value
                              ? Colors.black45
                              : null,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      controller.changeIsWordSelect(false);
                      flashcardController.changeIsShowShowWordOnFontCard(false);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: !controller.isWordSelect.value
                                ? Colors.amber
                                : Colors.black12,
                            width: 2),
                      ),
                      child: Text(
                        "Định nghĩa",
                        style: TextStyle(
                          color: controller.isWordSelect.value
                              ? Colors.black45
                              : null,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      width: ClientUtils.getDeviceWidth(context),
      height: ClientUtils.getHeightDevice(context) * 0.65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            topBottomSheet(),
            bodyBottomSheet(),
            bottomBottomSheet(),
          ],
        ),
      ),
    );
  }
}

class BottomSheetController extends GetxController {
  RxBool isSwitch = true.obs;
  RxBool isWordSelect = true.obs;
  RxBool isRandomCard = false.obs;
  RxBool isPronounce = false.obs;
  void changeIsPronounce() {
    isPronounce.value = !isPronounce.value;
    update();
  }

  void changeIsRandomCard() {
    isRandomCard.value = !isRandomCard.value;
    update();
  }

  void changeSwitch() {
    isSwitch.value = !isSwitch.value;
    update();
  }

  void changeIsWordSelect(bool value) {
    isWordSelect.value = value;
    update();
  }
}
