import 'package:flutter/material.dart';
import 'package:tapit/constants/string_constants.dart';

class HowToPlay extends StatelessWidget {
  const HowToPlay({super.key});
  static const String routeName = '/how-to-play';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          StringConstants.howToPlay,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 20, fontFamily: 'Lato'),
                  children: const [
                    TextSpan(
                      text: '•  Tapit is a',
                    ),
                    TextSpan(
                      text: ' two ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'player game.',
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                '•  Each player has to constantly tap on the color on their side to fill out the whole screen with their color.',
                maxLines: 5,
                style: TextStyle(fontSize: 20, fontFamily: 'Lato'),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                '•  First player to fill out the screen with their color wins the game.',
                style: TextStyle(fontSize: 20, fontFamily: 'Lato'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
