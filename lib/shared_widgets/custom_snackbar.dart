import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackbar {
  static void show({
    required String title,
    required String message,
    bool isError = false,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? Colors.red[50] : Colors.blue[50],
      colorText: isError ? Colors.red[700] : Colors.blue[700],
      borderRadius: 12,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutQuart,
      reverseAnimationCurve: Curves.easeInQuart,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: isError ? Colors.red[700] : Colors.blue[700],
        size: 28,
      ),
      boxShadows: [
        BoxShadow(
          color: (isError ? Colors.red[200] : Colors.blue[200])!.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      overlayBlur: 0,
      overlayColor: Colors.black12,
    );
  }

  static void showSuccess(String message) {
    show(
      title: 'Success',
      message: message,
      isError: false,
    );
  }

  static void showError(String message) {
    show(
      title: 'Error',
      message: message,
      isError: true,
    );
  }
}
