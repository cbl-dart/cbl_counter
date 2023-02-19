// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: avoid_classes_with_only_static_members, lines_longer_than_80_chars, directives_ordering, avoid_redundant_argument_values

// **************************************************************************
// TypedDatabaseGenerator
// **************************************************************************

import 'package:cbl/cbl.dart';
import 'package:cbl/src/typed_data_internal.dart';
import 'package:cbl_counter/src/data/counter_repository.dart';

class CounterDatabase extends $CounterDatabase {
  static Future<AsyncDatabase> openAsync(
    String name, [
    DatabaseConfiguration? config,
  ]) =>
      // ignore: invalid_use_of_internal_member
      AsyncDatabase.openInternal(name, config, _adapter);

  static SyncDatabase openSync(
    String name, [
    DatabaseConfiguration? config,
  ]) =>
      // ignore: invalid_use_of_internal_member
      SyncDatabase.internal(name, config, _adapter);

  static final _adapter = TypedDataRegistry(
    types: [
      TypedDocumentMetadata<CounterChange, MutableCounterChange>(
        dartName: 'CounterChange',
        factory: ImmutableCounterChange.internal,
        mutableFactory: MutableCounterChange.internal,
        typeMatcher: const ValueTypeMatcher(
          path: ['type'],
        ),
      ),
    ],
  );
}
