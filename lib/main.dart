import 'package:flutter/material.dart';
import 'package:tapit/screens/about.dart';
import 'package:tapit/screens/game_screen.dart';
import 'package:tapit/screens/home.dart';
import 'package:tapit/screens/howtoplay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tapit',
      theme: ThemeData(
        fontFamily: 'Lato',
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      initialRoute: Home.routeName,
      routes:  {
        Home.routeName: (context) => const Home(),
        GameScreen.routeName: (context) => const GameScreen(),
        HowToPlay.routeName: (context) => const HowToPlay(),
        About.routeName: (context) => const About()
      },
    );
  }
}