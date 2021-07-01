import 'package:flashcard/components/item_button_progess.dart';
import 'package:flashcard/utils/client_utils.dart';
import 'package:flashcard/utils/image_app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomSheetUserGuildCustom extends StatelessWidget {
  Widget itemBottomSheet(String image, String title, String description) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          Image(
            width: 40,
            height: 80,
            image: AssetImage(
              AppImage.iconSuccess,
              package: 'flashcard',
            ),
            fit: BoxFit.scaleDown,
          ),
          SizedBox(width: 20),
          Container(
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: title + "\n",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
                TextSpan(
                    text: description,
                    style: TextStyle(
                      height: 1.5,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    )),
              ]),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ClientUtils.getDeviceWidth(context),
      height: ClientUtils.getHeightDevice(context) * 0.65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
              "Điều hướng hỏi nhanh",
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                itemBottomSheet(
                  "aaaa",
                  "Chạm vào thẻ",
                  "Xem mặt còn lại",
                ),
                itemBottomSheet(
                  "aaaa",
                  "Vuốt sang trái",
                  "Tiếp tục học thẻ đó",
                ),
                itemBottomSheet(
                  "aaaa",
                  "Vuốt sang phải",
                  "Đánh dấu thẻ là đã biết",
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 20),
            child: ItemButtonProgess(
              title: "OK",
              onTap: () {
               Get.back();
              },
              backGroundColor: Colors.cyan,
            ),
          )
        ],
      ),
    );
  }
}
