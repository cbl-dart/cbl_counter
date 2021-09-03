import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/errors.dart';

/// Loading page, which is displayed while the app is initializing.
class InitializationPage extends StatefulWidget {
  const InitializationPage({
    Key? key,
    required this.initialize,
    required this.builder,
  }) : super(key: key);

  /// Callback which kicks of the initialization of the app.
  final AsyncCallback initialize;

  final WidgetBuilder builder;

  @override
  State<InitializationPage> createState() => _InitializationPageState();
}

class _InitializationPageState extends State<InitializationPage> {
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();

    _initialization = Future.sync(widget.initialize);
    _initialization.onError(recordUnexpectedError);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          Widget child;

          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              child = const _Content(hasError: true);
            } else {
              child = widget.builder(context);
            }
          } else {
            child = const _Content(hasError: false);
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: child,
          );
        },
      );
}

class _Content extends StatelessWidget {
  const _Content({
    Key? key,
    required this.hasError,
  }) : super(key: key);

  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final icon = hasError ? Icons.error : Icons.hourglass_empty;
    final message = hasError ? 'Error initializing' : 'Initializing...';

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
}
