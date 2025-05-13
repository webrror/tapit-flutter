import 'package:flutter/material.dart';
import 'package:tapit/constants/string_constants.dart';
import 'package:tapit/screens/about.dart';
import 'package:tapit/screens/game_screen.dart';
import 'package:tapit/screens/home.dart';
import 'package:tapit/screens/howtoplay.dart';

class TapitApp extends StatelessWidget {
  const TapitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: StringConstants.appName,
      theme: ThemeData(
        fontFamily: 'Lato',
        useMaterial3: true,
        brightness: Brightness.light,
        pageTransitionsTheme: PageTransitionsTheme(
          // builders: {
          //   TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          // },
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
        pageTransitionsTheme: PageTransitionsTheme(
          // builders: {
          //   TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          // },
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
  }
}
