import 'package:path_provider/path_provider.dart';

import '../utils/file_system.dart';

class AppEnvironment {
  AppEnvironment({
    required this.logsDirectory,
    required this.cblLogsDirectory,
    required this.syncGatewayUrl,
  });

  static Future<void> init() async {
    final filesDirectory = await getApplicationSupportDirectory();
    final logsDirectory = filesDirectory.subDirectory('logs');
    final cblLogsDirectory = logsDirectory.subDirectory('CouchbaseLite');

    await createAllDirectories([logsDirectory, cblLogsDirectory]);

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
