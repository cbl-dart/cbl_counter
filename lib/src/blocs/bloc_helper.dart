import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/errors.dart';

enum ActionStatus {
  none,
  active,
  success,
  failure,
}

enum ProcessStatus {
  stopped,
  running,
  error,
}

mixin BlocHelper on ChangeNotifier {
  bool get isDisposed => _isDisposed;
  var _isDisposed = false;

  @protected
  void runAction(
    Future<void> Function() action, {
    required ValueGetter<ActionStatus> getStatus,
    required ValueSetter<ActionStatus> setStatus,
  }) {
    assert(getStatus() != ActionStatus.active);

    Future.sync(action).then(
      (_) {
        assert(getStatus() == ActionStatus.active);
        setState(() {
          setStatus(ActionStatus.success);
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        assert(getStatus() == ActionStatus.active);
        setState(() {
          setStatus(ActionStatus.failure);
        });
        reportUnexpectedError(error, stackTrace);
      },
    );

    setState(() {
      setStatus(ActionStatus.active);
    });
  }

  @protected
  void startProcess(
    Stream<void> Function() process, {
    required ValueGetter<ProcessStatus> getStatus,
    required ValueSetter<ProcessStatus> setStatus,
    required ValueSetter<StreamSubscription<void>?> setSubscription,
  }) {
    assert(getStatus() != ProcessStatus.running);

    final subscription =
        Future.sync(process).asStream().asyncExpand((stream) => stream).listen(
      null,
      onDone: () {
        assert(getStatus() == ProcessStatus.running);
        setState(() {
          setStatus(ProcessStatus.stopped);
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        assert(getStatus() == ProcessStatus.running);
        setState(() {
          setStatus(ProcessStatus.error);
        });
        reportUnexpectedError(error, stackTrace);
      },
      cancelOnError: true,
    );

    setState(() {
      setSubscription(subscription);
      setStatus(ProcessStatus.running);
    });
  }

  @protected
  void stopProcess({
    required ValueGetter<ProcessStatus> getStatus,
    required ValueSetter<ProcessStatus> setStatus,
    required ValueGetter<StreamSubscription<void>?> getSubscription,
    required ValueSetter<StreamSubscription<void>?> setSubscription,
  }) {
    assert(getStatus() == ProcessStatus.running);

    getSubscription()!.cancel();
    setState(() {
      setSubscription(null);
      setStatus(ProcessStatus.stopped);
    });
  }

  @protected
  void setState(void Function() setState) {
    if (!_isDisposed) {
      setState();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
