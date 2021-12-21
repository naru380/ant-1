import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'ui/top/top_view_model.dart';
import 'ui/play/play_view_model.dart';
import 'ui/create/create_view_model.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      child: ScreenUtilInit(
        designSize: Size(360, 690),
        builder: () => MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.blue,
          sliderTheme: SliderThemeData(
              // activeTickMarkColor: Colors.white,
              // inactiveTickMarkColor: Colors.white,
              // thumbColor: Colors.black,
              )
          // visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
      title: 'logicmaker',
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
