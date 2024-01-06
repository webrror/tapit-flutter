import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:lottie/lottie.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  static const String routeName = '/game-screen';
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool intialState = true;
  double orange = 0;
  double purple = 0;
  double limit = 0;
  double diff = 28;

  @override
  Widget build(BuildContext context) {
    if (intialState) {
      var intialHeight = MediaQuery.of(context).size.height;
      setState(() {
        orange = intialHeight / 2;
        purple = intialHeight / 2;
        limit = intialHeight - 30;
        intialState = false;
      });
    }

    void onTapOrange() {
      if (orange > limit) {
        Dialogs.materialDialog(
            color: Colors.white,
            context: context,
            title: 'Orange Won!',
            barrierDismissible: false,
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    intialState = true;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Restart'),
              ),
            ],
            lottieBuilder: Lottie.asset('assets/animations/winner.json'));
      } else {
        setState(() {
          orange = orange + diff;
          purple = purple - diff;
          //print('Orange : $orange');
        });
      }
    }

    void onTapPurple() {
      if (purple > limit) {
        Dialogs.materialDialog(
          color: Colors.white,
          context: context,
          title: 'Purple Won!',
          barrierDismissible: false,
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  intialState = true;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Restart'),
            ),
          ],
            lottieBuilder: Lottie.asset('assets/animations/winner.json'));
      } else {
        setState(() {
          orange = orange - diff;
          purple = purple + diff;
          //print('Purple : $purple');
        });
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            GestureDetector(
              onTap: onTapOrange,
              child: Container(
                color: Colors.deepOrangeAccent,
                height: orange,
              ),
            ),
            GestureDetector(
              onTap: onTapPurple,
              child: Container(
                color: Colors.deepPurpleAccent,
                height: purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
