import 'dart:ui';

import 'package:flashcard/components/components.dart';
import 'package:flashcard/flashcard.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlashcardController extends GetxController {
  RxList<FlashCardModel> listHocLai = <FlashCardModel>[].obs;
  final listDataOld = <FlashCardModel>[].obs;
  RxList<FlashCardModel> listData = <FlashCardModel>[
    new FlashCardModel(
        word: "Viet Nam",
        define: 'Nước cộng hoà xã hội chủ nghĩa Việt Nam! <3'),
    new FlashCardModel(word: "Chelsea", define: 'to quoc viet nam',image: "https://thietbidoandoi.com/wp-content/uploads/2021/03/la-co-to-quoc.png"),
    new FlashCardModel(word: "ManU", define: 'losser'),
    new FlashCardModel(word: "Ha Noi", define: 'Mot tinh cua mien bac'),
    new FlashCardModel(word: "Bac Ninh", define: 'Quan ho...'),
  ].obs;
  RxList<FlashCardModel> listCardRemoved = <FlashCardModel>[].obs;
  Rx<Color> understood = Colors.white.obs;
  Rx<Color> learnAgain = Color(0xffffff).obs;
  Rx<StatusUser> statusUser = StatusUser.reading.obs;
  RxInt indexCard = 0.obs;
  RxInt countUnderstood = 0.obs;
  RxInt countLearnAgain = 0.obs;
  RxBool isPause = false.obs;
  RxBool isShowStatusCard =
      true.obs; // hien thi trang thai da hieu ma chua hieu
  RxBool isShowShowWordOnFontCard = true.obs;
  Rx<TCardController> tCardcontroller = TCardController().obs;
  var cardKeys = Map<int, GlobalKey<FlipCardState>>();
  RxList<Widget> data=<Widget>[].obs;


  List<Widget> createCard(){
    return List.generate(
      listData.length,
          (index) {
        cardKeys.putIfAbsent(
          index,
              () => GlobalKey<FlipCardState>(
            debugLabel: index.toString(),
          ),
        );
        GlobalKey<FlipCardState>? thisCard =
        cardKeys[index];
        return Container(
          child: ItemCard(index, thisCard),
        );
      },
    );
  }
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // for(int i=0;i<60;i++){
    //   listData.value.add(new FlashCardModel(word: "Chelsea", define: 'to quoc viet nam',image: "https://thietbidoandoi.com/wp-content/uploads/2021/03/la-co-to-quoc.png"));
    // }
    data.value = createCard();
  }
  @override
  void onReady() {
    super.onReady();
    listDataOld.value = listData.value;
  }

  void shuffleDataCard(bool value) {
    listHocLai.value = [];
    indexCard.value = 0;
    countUnderstood.value = 0;
    countLearnAgain.value = 0;
    listData.value = [];
    listData.value.addAll(listDataOld);
    if (value) {
      listData.value.shuffle();
      tCardcontroller.value.reset(
          cards: createCard().toList());
    } else {
      tCardcontroller.value.reset(
          cards: createCard().toList());
    }
    update();
  }

  void changeIsShowShowWordOnFontCard(bool value) {
    isShowShowWordOnFontCard.value = value;
    update();
  }

  void changeIsShowStatusCard(bool value) {
    isShowStatusCard.value = value;
    update();
  }

  void decrementCountUnderstood() {
    countUnderstood.value = countUnderstood.value - 1;
    update();
  }

  void decrementCountLearnAgain() {
    countLearnAgain.value = countLearnAgain.value - 1;
    update();
  }

  void changePauseButton() {
    isPause.value = !isPause.value;
    update();
  }

  void hocLaiTatCa() {
    listHocLai.value = [];
    indexCard.value = 0;
    countUnderstood.value = 0;
    countLearnAgain.value = 0;
    listData.value = [];
    listData.value.addAll(listDataOld);
    tCardcontroller.value.reset(
        cards: createCard().toList());
    update();
  }

  void hocLaiTuChuaHoc() {
    indexCard.value = 0;
    countUnderstood.value = 0;
    countLearnAgain.value = 0;
    listData.value = listHocLai.value;
    listHocLai.value = [];
    tCardcontroller.value.reset(
        cards: createCard().toList());
    update();
  }

  void increaseUnderstood() {
    countUnderstood.value = countUnderstood.value + 1;
    update();
  }

  void increaseLearnAgain(int index) {
    listHocLai.add(listData.value[index - 1]);
    countLearnAgain.value = countLearnAgain.value + 1;
    update();
  }

  void nextCard(int index) {
    indexCard.value = index;
    update();
  }

  void increaseCardRemoved(int index) {
    listCardRemoved.value.insert(0, listData[index]);
    update();
  }

  void changColorAndStatus(StatusUser status) {
    switch (status) {
      case StatusUser.reading:
        {
          understood.value = Colors.white;
          statusUser.value = status;
          update();
          break;
        }
      case StatusUser.understood:
        {
          understood.value = Colors.green;
          statusUser.value = status;
          update();
          break;
        }
      case StatusUser.learnAgain:
        {
          understood.value = Colors.amber.withOpacity(0.6);
          statusUser.value = status;
          update();
          break;
        }
    }
  }
}

enum StatusUser {
  understood,
  learnAgain,
  reading,
}
