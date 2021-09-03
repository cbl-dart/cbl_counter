import 'package:flutter/material.dart';

import 'initialization.dart';
import 'core/context.dart';
import 'pages/counter_page.dart';
import 'pages/initialization_page.dart';

class CounterApp extends StatelessWidget {
  const CounterApp({Key? key, required this.initializer}) : super(key: key);

  final AppInitializer initializer;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(colorScheme: const ColorScheme.light()),
      darkTheme: ThemeData.from(colorScheme: const ColorScheme.dark()),
      navigatorKey: navigatorKey,
      builder: (context, child) => InitializationPage(
        initialize: initializer.ensureInitialized,
        builder: (context) => ProvideRootDependencies(
          dependencies: initializer.rootDependencies,
          child: child!,
        ),
      ),
      home: CounterPage.withProviders(id: 'A'),
    );
  }
}
