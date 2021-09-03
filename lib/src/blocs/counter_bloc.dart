import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/counter_repository.dart';
import 'bloc_helper.dart';

/// Bloc which manages the interactions with a single counter.
class CounterBloc extends ChangeNotifier with BlocHelper {
  CounterBloc({
    required this.id,
    required this.counterRepository,
  });

  final String id;
  final CounterRepository counterRepository;

  int? get count => _count;
  int? _count;

  bool get isLoaded => count != null;

  ActionStatus get fetchStatus => _fetchStatus;
  ActionStatus _fetchStatus = ActionStatus.none;

  ActionStatus get updateStatus => _updateStatus;
  ActionStatus _updateStatus = ActionStatus.none;

  ProcessStatus get watchStatus => _watchStatus;
  ProcessStatus _watchStatus = ProcessStatus.stopped;

  ProcessStatus get syncStatus => _syncStatus;
  ProcessStatus _syncStatus = ProcessStatus.stopped;

  StreamSubscription? _watchSubscription;
  StreamSubscription? _syncSubscription;

  void fetch() {
    runAction(
      () async => _count = await counterRepository.counterValue(id),
      getStatus: () => _fetchStatus,
      setStatus: (value) => _fetchStatus = value,
    );
  }

  void increment() => _updateValue(delta: 1);

  void reset() {
    assert(isLoaded);
    _updateValue(delta: -count!);
  }

  void startWatching() {
    startProcess(
      () => counterRepository.watchCounterValue(id).map((value) {
        setState(() {
          _count = value;
        });
      }),
      getStatus: () => _watchStatus,
      setStatus: (value) => _watchStatus = value,
      setSubscription: (value) => _watchSubscription = value,
    );
  }

  void stopWatching() {
    stopProcess(
      getStatus: () => _watchStatus,
      setStatus: (value) => _watchStatus = value,
      getSubscription: () => _watchSubscription,
      setSubscription: (value) => _watchSubscription = value,
    );
  }

  void startSync() {
    startProcess(
      () => counterRepository.syncCounter(id),
      getStatus: () => _syncStatus,
      setStatus: (value) => _syncStatus = value,
      setSubscription: (value) => _syncSubscription = value,
    );
  }

  void stopSync() {
    stopProcess(
      getStatus: () => _syncStatus,
      setStatus: (value) => _syncStatus = value,
      getSubscription: () => _syncSubscription,
      setSubscription: (value) => _syncSubscription = value,
    );
  }

  void _updateValue({required int delta}) {
    assert(isLoaded);
    runAction(
      () {
        // Optimistically update the count.
        final oldCount = _count;
        setState(() {
          _count = _count! + delta;
        });

        return counterRepository
            .updateCounterValue(id, delta: delta)
            .catchError((error) {
          // Restore the old count if there is an error.
          setState(() {
            _count = oldCount;
          });
          throw error;
        });
      },
      getStatus: () => _updateStatus,
      setStatus: (value) => _updateStatus = value,
    );
  }

  @override
  void dispose() {
    if (syncStatus == ProcessStatus.running) {
      stopSync();
    }
    if (watchStatus == ProcessStatus.running) {
      stopWatching();
    }

    super.dispose();
  }
}
