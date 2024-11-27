import 'dart:async';

import 'package:cbl/cbl.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

import '../core/environment.dart';

part 'counter_repository.cbl.type.g.dart';

/// Repository to persist counters.
class CounterRepository {
  CounterRepository({required this.database});

  final Database database;

  /// Returns the current value of the counter with the given [id] from the
  /// database.
  Future<int> counterValue(String id) async {
    final query = await _buildCounterValueQuery();
    await query.setParameters(Parameters({'COUNTER_ID': id}));
    final resultSet = await query.execute();
    return _countValueQueryResult(resultSet);
  }

  /// Returns a stream of the value of the counter with the given [id], which
  /// emits a new value when the counter changes.
  Stream<int> watchCounterValue(String id) => Future(() async {
        final query = await _buildCounterValueQuery();
        await query.setParameters(Parameters({'COUNTER_ID': id}));
        return query;
      })
          .asStream()
          .asyncExpand((query) => query.changes())
          .asyncMap((change) => _countValueQueryResult(change.results));

  /// Updates the value of the counter with the given [id], by adding a [delta]
  /// value to it.
  ///
  /// The [delta] can be both positive or negative.
  Future<void> updateCounterValue(String id, {required int delta}) async {
    final collection = await database.defaultCollection;
    await collection
        .saveTypedDocument(MutableCounterChange(
          counterId: id,
          channels: ['counter/$id'],
          delta: delta,
          time: DateTime.now().toUtc(),
        ))
        .withConcurrencyControl();
  }

  /// Returns a stream, which synchronizes the counter with the given [id] with
  /// the Sync Gateway, while it is being listened to.
  Stream<void> syncCounter(String id) => Future(() async {
        final config = ReplicatorConfiguration(
          target: UrlEndpoint(appEnvironment.syncGatewayUrl),
          continuous: true,
          // Only push the selected counter.
          typedPushFilter: (document, flags) {
            if (document is CounterChange) {
              return document.counterId == id;
            }
            return false;
          },
        )..addCollection(
            await database.defaultCollection,
            CollectionConfiguration(
              // Only pull the selected counter.
              channels: ['counter/$id'],
            ),
          );

        return Replicator.createAsync(config);
      }).asStream().asyncExpand((replicator) => Rx.merge([
            // Emit all errors from the replicator into the stream.
            replicator.changes().map((change) {
              final error = change.status.error;
              if (error != null) {
                throw error;
              }
            }),

            // By starting the replicator in a microtask we ensure the error
            // stream above is subscribed to before that.
            Future.microtask(replicator.start).asStream(),
          ])
              // Close (which also stops) the replicator when the stream is
              // canceled.
              .doOnCancel(replicator.close));

  Future<AsyncQuery> _buildCounterValueQuery() async {
    final counterId = Expression.property('counterId');
    var deltaSum = Function_.sum(Expression.property('delta'));

    return QueryBuilder.createAsync()
        .select(SelectResult.expression(deltaSum))
        .from(DataSource.collection(await database.defaultCollection))
        .where(counterId.equalTo(Expression.parameter('COUNTER_ID')))
        .groupBy(counterId);
  }

  Future<int> _countValueQueryResult(ResultSet resultSet) async {
    final results = await resultSet.allResults();
    return results.firstOrNull?.integer(0) ?? 0;
  }
}

@TypedDocument()
abstract class CounterChange with _$CounterChange {
  factory CounterChange({
    required String counterId,
    required List<String> channels,
    required int delta,
    required DateTime time,
  }) = MutableCounterChange;

  @DocumentId()
  String get id;
}

@TypedDatabase(types: {CounterChange})
abstract class $CounterDatabase {}
