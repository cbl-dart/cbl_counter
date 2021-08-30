import 'package:cbl/cbl.dart';
import 'package:cbl_flutter/cbl_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'core/environment.dart';
import 'data/counter_repository.dart';

abstract class AppConfiguration {
  Future<void> initialize();

  RootDependencies get rootDependencies;
}

class RootDependencies {
  RootDependencies({required this.counterRepository});

  final CounterRepository counterRepository;
}

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

class DefaultAppConfiguration extends AppConfiguration {
  late final AsyncDatabase _database;

  @override
  Future<void> initialize() async {
    await Future.wait([
      AppEnvironment.init(),
      CouchbaseLiteFlutter.init(),
    ]);

    _setupCouchbaseLogging();
    await _openDatabase();
  }

  void _setupCouchbaseLogging() {
    Database.log
      // For Flutter apps `Database.log.custom` is setup with a logger, which
      // logs to `print`, but only at log level `warning`.
      ..custom = DartConsoleLogger(kReleaseMode ? LogLevel.none : LogLevel.info)
      ..file.config = LogFileConfiguration(
        directory: appEnvironment.cblLogsDirectory,
        usePlainText: !kReleaseMode,
      );
  }

  Future<void> _openDatabase() async {
    // Comment out to reset the local database.
    // await Database.remove('counters');
    _database = await Database.openAsync('counters');
  }

  @override
  RootDependencies get rootDependencies => RootDependencies(
        counterRepository: CounterRepository(database: _database),
      );
}
