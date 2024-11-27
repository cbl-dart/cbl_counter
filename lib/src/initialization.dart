import 'dart:math';

import 'package:cbl/cbl.dart';
import 'package:cbl_flutter/cbl_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'core/environment.dart';
import 'data/counter_repository.cbl.database.g.dart';
import 'data/counter_repository.dart';

/// Initializer, which prepares the app for execution.
///
/// Tests can use an alternative implementation, instead of the
/// [DefaultAppInitializer].
abstract class AppInitializer {
  static Future<void>? _initialized;

  /// Ensures that the app is initialized. Can be called multiple times.
  Future<void> ensureInitialized() => _initialized ??= initialize();

  /// Performs the actual initialization.
  Future<void> initialize();

  /// Returns the root dependencies of the app.
  RootDependencies get rootDependencies;
}

/// The dependencies which are provided at the root of the app.
class RootDependencies {
  RootDependencies({required this.counterRepository});

  final CounterRepository counterRepository;
}

/// Provides the [RootDependencies] to the widget tree below.
class ProvideRootDependencies extends StatelessWidget {
  const ProvideRootDependencies({
    Key? key,
    required this.dependencies,
    required this.child,
  }) : super(key: key);

  final RootDependencies dependencies;
  final Widget child;

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider.value(value: dependencies.counterRepository),
        ],
        child: child,
      );
}

/// The default [AppInitializer], which fully initializes the app for production
/// or live development.
class DefaultAppInitializer extends AppInitializer {
  late final AsyncDatabase _database;

  @override
  Future<void> initialize() async {
    await TracingDelegate.install(DevToolsTracing());

    await Future.wait([
      AppEnvironment.init(),
      CouchbaseLiteFlutter.init(),
    ]);

    _setupCouchbaseLogging();
    await _openDatabase();
  }

  void _setupCouchbaseLogging() {
    Database.log
      // Per default, the log level is set to [LogLevel.warning]. In debug mode
      // we want to see all logs, in release mode we want to see no logs.
      ..console.level = kReleaseMode ? LogLevel.none : LogLevel.info
      ..file.config = LogFileConfiguration(
        directory: appEnvironment.cblLogsDirectory,
        usePlainText: !kReleaseMode,
      );
  }

  Future<void> _openDatabase() async {
    _database = await CounterDatabase.openAsync(
      // A new database is opened each time the app starts to ensure multiple
      // instances of the app, running in parallel, do not use the same
      // database. This is necessary because two or more replicators accessing
      // the same database can cause issues with locking of the database.
      'counters-${Random().nextInt(0xFFFFFF)}',
    );
  }

  @override
  RootDependencies get rootDependencies => RootDependencies(
        counterRepository: CounterRepository(database: _database),
      );
}
