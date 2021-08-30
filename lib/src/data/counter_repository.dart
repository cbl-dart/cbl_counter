import 'dart:async';

import 'package:cbl/cbl.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

import '../core/environment.dart';

class CounterRepository {
  CounterRepository({required this.database});

  final AsyncDatabase database;

  Future<int> counterValue(String id) async {
    final query = _buildCounterValueQuery();
    query.parameters = Parameters({'COUNTER_ID': id});
    final resultSet = await query.execute();
    return _countValueQueryResult(resultSet);
  }

  Stream<int> watchCounterValue(String id) {
    final query = _buildCounterValueQuery();
    query.parameters = Parameters({'COUNTER_ID': id});
    return query.changes().asyncMap(_countValueQueryResult);
  }

  Future<void> updateCounterValue(String id, {required int delta}) async {
    await database.saveDocument(MutableDocument({
      'type': 'CounterChange',
      'counterId': id,
      'channels': ['counter/$id'],
      'delta': delta,
      'time': DateTime.now().toUtc(),
    }));
  }

  Stream<void> syncCounter(String id) =>
      Replicator.createAsync(ReplicatorConfiguration(
        database: database,
        target: UrlEndpoint(appEnvironment.syncGatewayUrl),
        continuous: true,
        channels: ['counter/$id'],
        pushFilter: (document, flags) => document['counterId'].string == id,
      )).asStream().asyncExpand((replicator) {
        final errorsStream = replicator.changes().map((change) {
          final error = change.status.error;
          if (error != null) {
            throw error;
          }
        });

        return Rx.merge([
          errorsStream,
          replicator.start().asStream(),
        ]).doOnCancel(replicator.close);
      });

  AsyncQuery _buildCounterValueQuery() {
    final counterId = Expression.property('counterId');
    var deltaSum = Function_.sum(Expression.property('delta'));

    return QueryBuilder.createAsync()
        .select(SelectResult.expression(deltaSum))
        .from(DataSource.database(database))
        .where(counterId.equalTo(Expression.parameter('COUNTER_ID')))
        .groupBy(counterId);
  }

  Future<int> _countValueQueryResult(ResultSet resultSet) async {
    final results = await resultSet.allResults();
    return results.firstOrNull?.integer(0) ?? 0;
  }
}
