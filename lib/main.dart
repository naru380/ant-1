import 'package:ant_1/routes.dart';
import 'package:ant_1/ui/create/confirm_screen.dart';
import 'package:ant_1/ui/play/play_screen.dart';
import 'package:ant_1/ui/top/top_screen.dart';
import 'package:ant_1/ui/top/top_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/create/create_screen.dart';
import 'ui/play/play_view_model.dart';
import 'ui/setting/setting_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
          ChangeNotifierProvider(
          create: (_) => TopViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => PlayViewModel(),
        ),
      ],
      child: MyApp(),
    )
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

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  PageController _pageController;
  int _screen = 0;

  List<BottomNavigationBarItem> myBottomNavigationItems() {
    return [
      BottomNavigationBarItem(icon: Icon(Icons.book), title: const Text('Top')),
      BottomNavigationBarItem(
          icon: Icon(Icons.settings), title: const Text('Setting')),
    ];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _screen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _screen = index;
          });
        },
        children: [
          TopScreen(),
          SettingScreen(),
        ],
      ),
    );
  }
}
