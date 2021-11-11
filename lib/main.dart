import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'ui/top/top_view_model.dart';
import 'ui/play/play_view_model.dart';
import 'ui/create/create_view_model.dart';
import 'package:admob_flutter/admob_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Admob.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TopViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => PlayViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => CreateViewModel(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      title: 'logicmaker',
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
