import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../blocs/bloc_helper.dart';
import '../blocs/counter_bloc.dart';
import '../components/dot_decoration.dart';
import '../components/labeled_switch.dart';
import '../components/number_counter.dart';

/// Displays a counter and various controls for it.
class CounterPage extends StatefulWidget {
  const CounterPage({Key? key}) : super(key: key);

  static Widget withProviders({required String id}) => ChangeNotifierProvider(
        create: (context) => CounterBloc(
          id: id,
          counterRepository: context.read(),
        ),
        child: const CounterPage(),
      );

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  var _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      // Cannot call `startWatching` in a build method because it triggers a
      // rebuild.
      scheduleMicrotask(() => context.read<CounterBloc>().startWatching());
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<CounterBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Load from DB',
            onPressed: _invokeAction(bloc.fetchStatus, bloc.fetch),
          ),
          LabeledSwitch(
            label: const Text('Watch'),
            value: bloc.watchStatus == ProcessStatus.running,
            onChanged: (value) {
              if (value) {
                bloc.startWatching();
              } else {
                bloc.stopWatching();
              }
            },
          ),
          LabeledSwitch(
            label: const Text('Sync'),
            value: bloc.syncStatus == ProcessStatus.running,
            onChanged: (value) {
              if (value) {
                bloc.startSync();
              } else {
                bloc.stopSync();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset',
            onPressed: _invokeAction(bloc.updateStatus, bloc.reset),
          ),
        ],
      ),
      body: const Center(child: RepaintBoundary(child: _CounterGauge())),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        onPressed: _invokeAction(bloc.updateStatus, bloc.increment),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Displays the actual value of a counter.
class _CounterGauge extends StatelessWidget {
  const _CounterGauge({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<CounterBloc>();

    Widget content;
    if (bloc.isLoaded) {
      // The counter's value is loaded, so show it.
      content = NumberCounter(
        number: bloc.count!,
        style: Theme.of(context)
            .textTheme
            .displayLarge!
            .merge(GoogleFonts.robotoMono(fontWeight: FontWeight.w100)),
      );
    } else {
      if (bloc.fetchStatus == ActionStatus.active ||
          bloc.watchStatus == ProcessStatus.running ||
          (bloc.fetchStatus == ActionStatus.none &&
              bloc.watchStatus == ProcessStatus.stopped)) {
        // The counter bloc has not loaded a value yet, but also has no error.
        content = SizedBox.fromSize(
          size: const Size.square(140),
          child: const CircularProgressIndicator(),
        );
      } else {
        // The counter bloc could not load a value.
        content = const Icon(Icons.error);
      }
    }

    // Indicates that the counter has a pending update and the current value
    // has not been persisted yet.
    return DotDecoration(
      show: bloc.updateStatus == ActionStatus.active,
      alignment: Alignment.bottomCenter,
      // Lays out the content.
      child: Container(
        padding: const EdgeInsets.all(8.0),
        height: 180,
        // Animates changes to the content.
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: content,
        ),
      ),
    );
  }
}

VoidCallback _invokeAction(ActionStatus status, VoidCallback action) => () {
      if (status == ActionStatus.active) {
        // Ignore clicks while the action is active.
        return;
      }

      action();
    };
