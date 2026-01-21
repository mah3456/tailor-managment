import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class helpers {

  static message(BuildContext context){
    exit(0);
  }


  static SnackbarController customSnackBar({
    required String title,
    required String message,
    required Color background,
  }) {
    return Get.snackbar(
      title,
      message,
      backgroundColor: background,
      colorText: Colors.white,
    );
  }
}

