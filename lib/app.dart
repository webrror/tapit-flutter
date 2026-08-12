import 'package:flutter/material.dart';
import 'package:tapit/constants/string_constants.dart';
import 'package:tapit/screens/about.dart';
import 'package:tapit/screens/game_screen.dart';
import 'package:tapit/screens/home.dart';
import 'package:tapit/screens/howtoplay.dart';
import 'package:tapit/services/settings_service.dart';

class TapitApp extends StatelessWidget {
  const TapitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: StringConstants.appName,
          themeMode: SettingsService.instance.themeMode,
          theme: ThemeData(
            fontFamily: 'Lato',
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: Colors.deepPurpleAccent,
            scaffoldBackgroundColor: const Color(0xFFF8F9FD),
            pageTransitionsTheme: PageTransitionsTheme(
              builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
                TargetPlatform.values,
                value: (_) => const FadeForwardsPageTransitionsBuilder(),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            fontFamily: 'Lato',
            colorSchemeSeed: Colors.deepPurpleAccent,
            scaffoldBackgroundColor: const Color(0xFF12131A),
            pageTransitionsTheme: PageTransitionsTheme(
              builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
                TargetPlatform.values,
                value: (_) => const FadeForwardsPageTransitionsBuilder(),
              ),
            ),
          ),
          initialRoute: Home.routeName,
          routes: {
            Home.routeName: (context) => const Home(),
            GameScreen.routeName: (context) => const GameScreen(),
            HowToPlay.routeName: (context) => const HowToPlay(),
            About.routeName: (context) => const About(),
          },
        );
      },
    );
  }
}
