import 'package:flutter/material.dart';

class ItemButtonCustom extends StatefulWidget {
  Widget title;
  Function onTap;
  ItemButtonCustom({
    required this.title,
    required this.onTap,
  });
  @override
  _ItemButtonCustomState createState() => _ItemButtonCustomState();
}

class _ItemButtonCustomState extends State<ItemButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusColor: Colors.white,
      onTap: () {
        widget.onTap();
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: widget.title,
      ),
    );
  }
}
