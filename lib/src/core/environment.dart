import 'package:path_provider/path_provider.dart';

import '../utils/file_system.dart';

class AppEnvironment {
  AppEnvironment({
    required this.cblDatabaseDirectory,
    required this.logsDirectory,
    required this.cblLogsDirectory,
    required this.syncGatewayUrl,
  });

  static Future<void> init() async {
    final filesDirectory = await getApplicationSupportDirectory();
    final cblDatabaseDirectory = filesDirectory.subDirectory('CouchbaseLite');
    final logsDirectory = filesDirectory.subDirectory('logs');
    final cblLogsDirectory = logsDirectory.subDirectory('CouchbaseLite');

    await createAllDirectories([
      cblDatabaseDirectory,
      logsDirectory,
      cblLogsDirectory,
    ]);

    appEnvironment = AppEnvironment(
      cblDatabaseDirectory: cblDatabaseDirectory.path,
      logsDirectory: logsDirectory.path,
      cblLogsDirectory: cblLogsDirectory.path,
      syncGatewayUrl: Uri.parse(const String.fromEnvironment(
        'cbl_counter.syncGatewayUrl',
        defaultValue: 'ws://localhost:4984/counters',
      )),
    );
  }

  // TODO: remove when Couchbase Lite default database directory is consitent
  // across all platforms
  final String cblDatabaseDirectory;

  final String logsDirectory;

  final String cblLogsDirectory;

  final Uri syncGatewayUrl;
}

late final AppEnvironment appEnvironment;
