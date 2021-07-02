import 'package:flutter/material.dart';

class ItemButtonProgess extends StatelessWidget {
  String title;
  Color? colorText;
  Color? backGroundColor;
  Function onTap;

  ItemButtonProgess({
    required this.title,
     this.colorText,
    this.backGroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              splashColor: Colors.red,
              onTap: () {
                onTap();
              },
              child: Container(
                decoration: BoxDecoration(
                  color:backGroundColor ?? Colors.lightBlueAccent.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.lightBlueAccent.withOpacity(0.9),),
                ),
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:colorText ?? Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
