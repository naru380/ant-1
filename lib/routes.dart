import 'package:flutter/material.dart';
import 'ui/create/confirm_screen.dart';
import 'ui/create/create_screen.dart';
import 'ui/setting/setting_screen.dart';
import 'ui/top/top_screen.dart';
import 'ui/play/play_screen.dart';

class RouteGenerator {
  // ignore: missing_return
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => TopScreen()
        );
      case '/create':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CreateScreen(),
        );
      case '/confirm':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ConfirmScreen(),
        );
      case '/setting':
        return MaterialPageRoute(
          builder: (_) => SettingScreen(),
        );
      case '/play':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PlayScreen(),
        );
      }
    }
  }