import 'package:flutter/material.dart';

class SnackbarUtils {
  SnackbarUtils._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, Colors.green.shade700);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, Theme.of(context).colorScheme.error);
  }

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
