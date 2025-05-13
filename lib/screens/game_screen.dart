import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:tapit/constants/asset_constants.dart';
import 'package:tapit/constants/string_constants.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  static const String routeName = '/game-screen';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double orangeHeight = 0;
  double purpleHeight = 0;
  double heightLimit = 0;
  final double heightDiff = 25;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;
      setState(() {
        orangeHeight = screenHeight / 2;
        purpleHeight = screenHeight / 2;
        heightLimit = screenHeight - 10;
      });
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void resetGame() {
    final screenHeight = MediaQuery.of(context).size.height;
    setState(() {
      orangeHeight = screenHeight / 2;
      purpleHeight = screenHeight / 2;
    });
  }

  void showWinnerDialog(String winnerText) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(AssetConstants.winner, height: 250),
              Text(winnerText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    resetGame();
                  },
                  child: Text(StringConstants.restart),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onTapOrange() {
    if (orangeHeight > heightLimit) {
      showWinnerDialog(StringConstants.orangeWon);
    } else {
      setState(() {
        orangeHeight += heightDiff;
        purpleHeight -= heightDiff;
      });
    }
  }

  void onTapPurple() {
    if (purpleHeight > heightLimit) {
      showWinnerDialog(StringConstants.purpleWon);
    } else {
      setState(() {
        orangeHeight -= heightDiff;
        purpleHeight += heightDiff;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            GestureDetector(
              onTap: onTapOrange,
              child: Container(
                color: Colors.deepOrangeAccent,
                height: orangeHeight,
              ),
            ),
            GestureDetector(
              onTap: onTapPurple,
              child: Container(
                color: Colors.deepPurpleAccent,
                height: purpleHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
