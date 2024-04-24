import 'dart:io';

import 'package:cbl/cbl.dart';
import 'package:cbl_dart/cbl_dart.dart';

Future<void> initCouchbaseLiteForTest() async {
  final tempDir = await Directory.systemTemp.createTemp();
  // ignore: avoid_print
  print('CBL tmp dir: ${tempDir.path}');

  await CouchbaseLiteDart.init(
    edition: Edition.community,
    filesDir: tempDir.path,
  );
}

extension DatabaseExt on Database {
  Stream<String> allDocumentIds(Collection collection) =>
      Future.sync(() => createQuery(
                'SELECT META().id '
                'FROM ${collection.scope.name}.${collection.name}',
              ))
          .asStream()
          .asyncMap((query) => query.execute())
          .asyncExpand((resultSet) => resultSet.asStream())
          .map((result) => result.value(0)!);

  Future<void> deleteAllDocuments(Collection collection) async =>
      inBatch(() async {
        await for (final id in allDocumentIds(collection)) {
          await collection.deleteDocument((await collection.document(id))!);
        }
      });
}
