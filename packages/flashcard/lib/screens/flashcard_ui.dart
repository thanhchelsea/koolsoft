import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flashcard/components/animation.dart';
import 'package:flashcard/components/bottomsheet_user_guild_component.dart';
import 'package:flashcard/components/components.dart';
import 'package:flashcard/components/item_button_progess.dart';
import 'package:flashcard/screens/flashcard_controller.dart';
import 'package:flashcard/utils/client_utils.dart';
import 'package:flashcard/utils/image_app.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'flashcard_binding.dart';

class FlashCardUi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: FlashcardBinding(),
      home: Scaffold(
        backgroundColor: Colors.lightBlue.withOpacity(0.03),
        body: Container(
          width: ClientUtils.getDeviceWidth(context),
          height: ClientUtils.getHeightDevice(context),
          child: FlashcardAnimation(),
        ),
      ),
    );
  }
}

class FlashcardAnimation extends StatefulWidget {
  @override
  _FlashcardAnimationState createState() => _FlashcardAnimationState();
}

class _FlashcardAnimationState extends State<FlashcardAnimation> {
  GlobalKey<FlipCardState>? lastFlipped;
  FlashcardController controllerFlashcard =
      Get.put<FlashcardController>(FlashcardController());
  List<Widget> cards = <Widget>[];
  List<Widget>? data;
  GlobalKey<FlipCardState>? thisCard;
  Timer? timer;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<FlashcardController>(
        builder: (controller) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  Container(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          width: ClientUtils.getDeviceWidth(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.arrow_back_rounded),
                              Text(
                                "${controller.indexCard}/${controller.listData.length}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    Get.bottomSheet(
                                      BottomSheetUserGuildCustom(),
                                      isScrollControlled: true,
                                    );
                                  },
                                  icon: Icon(Icons.help))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        topScreen(context),
                        bodyScreen(context),
                        bottomScreen(),
                      ],
                    ),
                  )
                ],
              ),
              controller.indexCard.value != controller.listData.length
                  ? Container()
                  : Container(
                      height: ClientUtils.getHeightDevice(context) * 0.7,
                      child: Center(
                        child: learnSuccess(context),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget bodyScreen(BuildContext context) {
    data = List.generate(
      controllerFlashcard.listData.length,
      (index) {
        controllerFlashcard.cardKeys.putIfAbsent(
          index,
          () => GlobalKey<FlipCardState>(
            debugLabel: index.toString(),
          ),
        );
        GlobalKey<FlipCardState>? thisCard =
            controllerFlashcard.cardKeys[index];
        return Container(
          child: ItemCard(index, thisCard),
        );
      },
    );
    return GetBuilder<FlashcardController>(
      builder: (controller) {
        return Expanded(
            child: Container(
          alignment: Alignment.bottomCenter,
          child: TCard(
            cards: data ?? [],
            size: Size(ClientUtils.getDeviceWidth(context) * 0.9,
                ClientUtils.getHeightDevice(context) * 0.7),
            controller: controller.tCardcontroller.value,
            onForward: (index, info) {
              if (info.direction == SwipDirection.Right) {
                controller.changColorAndStatus(StatusUser.understood);
                controller.nextCard(index);
                controller.increaseUnderstood();
              }
              if (info.direction == SwipDirection.Left) {
                controller.changColorAndStatus(StatusUser.learnAgain);
                controller.nextCard(index);
                controller.increaseLearnAgain(index);
              }
              if (info.direction == SwipDirection.None) {
                controller.changColorAndStatus(StatusUser.reading);
              }
              controller.changColorAndStatus(StatusUser.reading);
            },
            onBack: (index, info) {
              controller.nextCard(controller.indexCard.value - 1);
              if (info.direction == SwipDirection.Right) {
                controllerFlashcard.decrementCountUnderstood();
              }
              if (info.direction == SwipDirection.Left) {
                controllerFlashcard.decrementCountLearnAgain();
              }
            },
            onEnd: () {},
            onDragEnd: () {
              controller.changColorAndStatus(StatusUser.reading);
            },
            updateMove: (details) {
              if (details.delta.dx < 0) {
                controller.changColorAndStatus(StatusUser.learnAgain);
              }
              if (details.delta.dx > 0) {
                controller.changColorAndStatus(StatusUser.understood);
              }
            },
          ),
        ));
      },
    );
  }

  Widget bottomScreen() {
    return GetBuilder<FlashcardController>(
      builder: (controller) {
        return Container(
          padding: EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              controller.isShowStatusCard.value
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child:
                              Text(controller.countLearnAgain.value.toString()),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.6),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          padding: EdgeInsets.all(8),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Text(
                            controller.countUnderstood.value.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ItemButtonCustom(
                    title: Icon(Icons.settings_backup_restore),
                    onTap: () {
                      //back
                      controller.tCardcontroller.value.back();
                    },
                  ),
                  ItemButtonCustom(
                    title: Text(
                      "Tùy chọn",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      // controller.tCardcontroller.value.reset(cards:data!.reversed.toList());
                      Get.bottomSheet(
                        BottomSheetOptionsComponent(),
                        isScrollControlled: true,
                      );
                    },
                  ),
                  ItemButtonCustom(
                    title: !controller.isPause.value
                        ? Icon(Icons.play_arrow)
                        : Icon(
                            Icons.pause,
                            color: Colors.amber,
                          ),
                    onTap: () {
                      if (controller.isPause.value) {
                        timer!.cancel();
                      } else {
                        if (controllerFlashcard
                                .cardKeys[controller.indexCard.value] !=
                            null)
                          controllerFlashcard
                              .cardKeys[controller.indexCard.value]!
                              .currentState
                              ?.toggleCard();
                        timer = Timer.periodic(
                          Duration(seconds: 5),
                          (timer) {
                            Future.delayed(
                              Duration(seconds: 1),
                              () {
                                if (controllerFlashcard
                                        .cardKeys[controller.indexCard.value] !=
                                    null)
                                  controllerFlashcard
                                      .cardKeys[controller.indexCard.value]!
                                      .currentState
                                      ?.toggleCard();
                              },
                            );
                            controller.tCardcontroller.value
                                .forward(direction: SwipDirection.Left);
                            controller
                                .changColorAndStatus(StatusUser.learnAgain);
                            if (controller.indexCard.value ==
                                controller.listData.length - 1) {
                              timer.cancel();
                              controller.changePauseButton();
                            }
                          },
                        );
                      }
                      controller.changePauseButton();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget topScreen(BuildContext context) {
    return GetBuilder<FlashcardController>(
      builder: (controller) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          margin: EdgeInsets.only(top: 10, bottom: 10),
          height: ClientUtils.getHeightDevice(context) * 0.01,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              value: (controller.indexCard.value / controller.listData.length),
              color: Colors.green,
              backgroundColor: Colors.white,
              semanticsLabel: 'Linear progress indicator',
            ),
          ),
        );
      },
    );
  }

  Widget learnSuccess(BuildContext context) {
    return GetBuilder<FlashcardController>(
      builder: (controller) {
        return controller.listHocLai.value.isEmpty
            ? itemSuccess(context)
            : itemHoiDeHocLai(context);
      },
    );
  }

  Widget itemSuccess(BuildContext context) {
    return GetBuilder<FlashcardController>(
      builder: (controller) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 50),
          padding: EdgeInsets.only(bottom: 10),
          width: ClientUtils.getDeviceWidth(context) * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      width: ClientUtils.getDeviceWidth(context) * 0.4,
                      height: ClientUtils.getHeightDevice(context) * 0.1,
                      image: AssetImage(
                        AppImage.iconSuccess,
                        package: 'flashcard',
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          "Làm tốt lắm!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    Text(
                      "Chúc mừng bạn!",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              ItemButtonProgess(
                title: "Học lại",
                onTap: () {
                  controller.hocLaiTatCa();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget itemHoiDeHocLai(BuildContext context) {
    return GetBuilder<FlashcardController>(
      builder: (controller) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 50),
          width: ClientUtils.getDeviceWidth(context) * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image(
                        width: ClientUtils.getDeviceWidth(context) * 0.4,
                        height: ClientUtils.getHeightDevice(context) * 0.1,
                        image: AssetImage(
                          AppImage.iconMatCuoi,
                          package: 'flashcard',
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          "Làm tốt lắm!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "Tiếp tục ôn luyện để nắm vững thuật ngữ còn lại ${controller.listHocLai.length}.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ItemButtonProgess(
                title: "Tiếp tục",
                onTap: () {
                  controller.hocLaiTuChuaHoc();
                },
              ),
              Container(
                padding: EdgeInsets.only(bottom: 6),
                child: ItemButtonProgess(
                  title: "Học lại",
                  backGroundColor: Colors.transparent,
                  colorText: Colors.lightBlueAccent.withOpacity(0.9),
                  onTap: () {
                    controller.hocLaiTatCa();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ItemCard extends StatelessWidget {
  int index;
  var thisCard;

  ItemCard(this.index, this.thisCard);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlashcardController>(
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: FlipCard(
            key: thisCard,
            flipOnTouch: true,
            front: InkWell(
              onTap: () {
                thisCard?.currentState?.toggleCard();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: [
                      controller.indexCard.value == index &&
                              controller.statusUser.value !=
                                  StatusUser.reading &&
                              controller.isShowStatusCard.value
                          ? Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: controller.understood.value,
                              ),
                              child: Text(
                                controller.statusUser.value ==
                                        StatusUser.understood
                                    ? "Hiểu rồi"
                                    : controller.statusUser.value ==
                                            StatusUser.learnAgain
                                        ? "Học lại"
                                        : "",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: controller.statusUser.value ==
                                          StatusUser.understood
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Container(),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          alignment: Alignment.centerLeft,
                          child: controller.listData[index].image == null
                              ? AutoSizeText(
                                  controller.isShowShowWordOnFontCard.value
                                      ? controller.listData[index].word
                                      : controller.listData[index].define,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontSize: 40),
                                )
                              : Image(
                                  image: NetworkImage(controller
                                      .listData[index].image
                                      .toString()),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            back: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Container(
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    controller.statusUser.value != StatusUser.reading &&
                            controller.isShowStatusCard.value
                        ? Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: controller.understood.value,
                            ),
                            child: Text(
                              controller.statusUser.value ==
                                      StatusUser.understood
                                  ? "Hiểu rồi"
                                  : controller.statusUser.value ==
                                          StatusUser.learnAgain
                                      ? "Học lại"
                                      : "",
                              style: TextStyle(
                                fontSize: 18,
                                color: controller.statusUser.value ==
                                        StatusUser.understood
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Container(),
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        alignment: Alignment.centerLeft,
                        child: AutoSizeText(
                          !controller.isShowShowWordOnFontCard.value
                              ? controller.listData[index].word
                              : controller.listData[index].define,
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
