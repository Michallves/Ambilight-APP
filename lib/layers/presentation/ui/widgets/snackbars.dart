import 'package:flutter/material.dart';

class SnackBars {
  static success(BuildContext context,
      {required String message, SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF52B841).withOpacity(0.9),
        action: action,
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(
              width: 16,
            ),
            Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ],
        )));
  }

  static info(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF353535).withOpacity(0.9),
        content: Row(
          children: [
            const Icon(
              Icons.info,
              color: Colors.white,
            ),
            const SizedBox(
              width: 16,
            ),
            Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ],
        )));
  }

  static error(BuildContext context,
      {required String message, SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.red,
        content: Row(
          children: [
            const Icon(
              Icons.error,
              color: Colors.white,
            ),
            const SizedBox(
              width: 16,
            ),
            Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ],
        )));
  }
}
