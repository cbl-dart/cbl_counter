import 'package:flutter/material.dart';

import 'context.dart';

void reportUnexpectedError(
  Object error,
  StackTrace stackTrace,
) {
  _showUnexpectedErrorDialog(error);
  recordUnexpectedError(error, stackTrace);
}

void _showUnexpectedErrorDialog(Object error) {
  showDialog(
    context: appContext,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Unexpected error'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [Text(error.toString())],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('OK'),
        )
      ],
    ),
  );
}

void recordUnexpectedError(Object error, StackTrace stackTrace) {
  FlutterError.reportError(FlutterErrorDetails(
    exception: error,
    stack: stackTrace,
    library: 'App',
    context: ErrorDescription('Unexpected error'),
  ));
}
