import 'package:flutter/material.dart';

import 'configuration.dart';
import 'core/context.dart';
import 'pages/counter_page.dart';
import 'pages/initialization_page.dart';

class CounterApp extends StatelessWidget {
  const CounterApp({Key? key, required this.config}) : super(key: key);

  final AppConfiguration config;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(colorScheme: const ColorScheme.light()),
      darkTheme: ThemeData.from(colorScheme: const ColorScheme.dark()),
      navigatorKey: navigatorKey,
      builder: (context, child) => InitializationPage(
        initialize: config.initialize,
        builder: (context) => ProvideRootDependencies(
          dependencies: config.rootDependencies,
          child: child!,
        ),
      ),
      home: CounterPage.withProviders(id: 'A'),
    );
  }
}
