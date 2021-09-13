import 'package:path_provider/path_provider.dart';

import '../utils/file_system.dart';

/// Configuration of the app for the environment it is running in.
class AppEnvironment {
  AppEnvironment({
    required this.logsDirectory,
    required this.cblLogsDirectory,
    required this.syncGatewayUrl,
  });

  /// Initialize the [appEnvironment].
  static Future<void> init() async {
    final filesDirectory = await getApplicationSupportDirectory();
    final logsDirectory = filesDirectory.subDirectory('logs');
    final cblLogsDirectory = logsDirectory.subDirectory('CouchbaseLite');

    await createAllDirectories([
      logsDirectory,
      cblLogsDirectory,
    ]);

    appEnvironment = AppEnvironment(
      logsDirectory: logsDirectory.path,
      cblLogsDirectory: cblLogsDirectory.path,
      syncGatewayUrl: Uri.parse(const String.fromEnvironment(
        'cbl_counter.syncGatewayUrl',
        defaultValue: 'ws://localhost:4984/counters',
      )),
    );
  }

  final String logsDirectory;

  final String cblLogsDirectory;

  final Uri syncGatewayUrl;
}

late final AppEnvironment appEnvironment;
