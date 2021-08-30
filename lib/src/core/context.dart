import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();

/// Top level [BuildContext] of the app, which can be used from anywhere.
BuildContext get appContext => navigatorKey.currentContext!;
