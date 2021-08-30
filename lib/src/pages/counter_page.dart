import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../blocs/bloc_helper.dart';
import '../blocs/counter_bloc.dart';
import '../components/dot_decoration.dart';
import '../components/labled_switch.dart';

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
            onPressed: () {
              if (bloc.fetchStatus == ActionStatus.active) {
                // Ignore clicks while an update is pending.
                return;
              }

              bloc.fetch();
            },
            icon: const Icon(Icons.download),
            tooltip: 'Load from DB',
          ),
          LabledSwitch(
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
          LabledSwitch(
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
            onPressed: () {
              if (bloc.updateStatus == ActionStatus.active) {
                // Ignore clicks while an update is pending.
                return;
              }

              bloc.reset();
            },
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Center(child: _buildCounter()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (bloc.updateStatus == ActionStatus.active) {
            // Ignore clicks while an update is pending.
            return;
          }

          bloc.increment();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCounter() {
    final bloc = context.watch<CounterBloc>();

    Widget child;
    if (bloc.isLoaded) {
      child = Text(
        '${bloc.count}',
        key: ValueKey(bloc.count),
        style: Theme.of(context)
            .textTheme
            .headline1!
            .merge(GoogleFonts.robotoMono(fontWeight: FontWeight.w100)),
      );
    } else {
      if (bloc.fetchStatus == ActionStatus.active ||
          bloc.watchStatus == ProcessStatus.running ||
          (bloc.fetchStatus == ActionStatus.none &&
              bloc.watchStatus == ProcessStatus.stopped)) {
        child = SizedBox.fromSize(
          size: const Size.square(140),
          child: const CircularProgressIndicator(),
        );
      } else {
        child = const Icon(Icons.error);
      }
    }

    child = Container(
      padding: const EdgeInsets.all(8.0),
      height: 180,
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: child,
      ),
    );

    return DotDecoration(
      show: bloc.updateStatus == ActionStatus.active,
      alignment: Alignment.bottomCenter,
      child: child,
    );
  }
}
