import 'package:flutter/material.dart';

import 'context.dart';

/// Reports an unexpected error to the user and the Flutter framework.
void reportUnexpectedError(
  Object error,
  StackTrace stackTrace,
) {
  _showUnexpectedErrorDialog(error);
  recordUnexpectedError(error, stackTrace);
}

/// Shows a dialog to the user, to notify them of an unexpected error.
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

/// Reports and unexpected error to the Flutter framework.
void recordUnexpectedError(Object error, StackTrace stackTrace) {
  FlutterError.reportError(FlutterErrorDetails(
    exception: error,
    stack: stackTrace,
    library: 'App',
    context: ErrorDescription('Unexpected error'),
  ));
}
