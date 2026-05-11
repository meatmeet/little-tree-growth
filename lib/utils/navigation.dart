import 'package:flutter/material.dart';

/// Navigate to a new screen by pushing it onto the navigator stack.
Future<T?> pushScreen<T>(BuildContext context, Widget screen) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => screen),
  );
}

/// Replace the current screen with a new one.
Future<T?> pushReplacementScreen<T>(BuildContext context, Widget screen) {
  return Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => screen),
  );
}

/// Navigate to a screen and remove all previous routes.
Future<T?> pushAndRemoveAll<T>(BuildContext context, Widget screen) {
  return Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => screen),
    (route) => false,
  );
}

/// Show a simple snackbar.
void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}
