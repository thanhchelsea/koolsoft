import 'package:flutter/cupertino.dart';

class ClientUtils {
  static double getHeightDevice(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getDeviceWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
}

enum typeUser {
  STUDENT,
  TEACHER,
  HR,
}
