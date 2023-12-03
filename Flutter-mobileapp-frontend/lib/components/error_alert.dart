import 'package:flutter/material.dart';

class ErrorAlert {
  final String errorMessage;

  const ErrorAlert({
    required this.errorMessage,
  });

  static show(
    BuildContext context,
    String errorMessage,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }
}
