import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/data_source.dart';
import 'services/storage.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await Storage.open();
  final state = AppState(storage, DataSource());
  unawaited(state.load());
  runApp(
    ChangeNotifierProvider<AppState>.value(
      value: state,
      child: TerritoryApp(state: state),
    ),
  );
}
