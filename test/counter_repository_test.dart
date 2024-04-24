import 'package:cbl/cbl.dart';
import 'package:cbl_counter/src/data/counter_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/database.dart';

void main() {
  late final AsyncDatabase db;
  late final CounterRepository repository;

  setUpAll(() async {
    await initCouchbaseLiteForTest();
    db = await Database.openAsync('test');
    repository = CounterRepository(database: db);
  });

  setUp(() async {
    await db.deleteAllDocuments(await db.defaultCollection);
  });

  test('counter value for new counter', () async {
    expect(await repository.counterValue('a'), 0);
  });

  test('updated counter', () async {
    await repository.updateCounterValue('a', delta: 1);
    expect(await repository.counterValue('a'), 1);

    await repository.updateCounterValue('a', delta: 2);
    expect(await repository.counterValue('a'), 3);

    await repository.updateCounterValue('a', delta: -1);
    expect(await repository.counterValue('a'), 2);
  });

  test('watch counter value', () {
    expect(
      repository.watchCounterValue('a').map((value) {
        // print(value);
        if (value < 3) {
          repository.updateCounterValue('a', delta: 1);
        }
        return value;
      }),
      emitsInOrder([0, 1, 2, 3]),
    );
  });
}
