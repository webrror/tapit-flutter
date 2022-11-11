import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HowToPlay extends StatelessWidget {
  const HowToPlay({super.key});
  static const String routeName = '/how-to-play';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to play'),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal:20.0, vertical: 20),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: GoogleFonts.lato(
                    color: Colors.black,
                    fontSize: 20
                  ),
                  children: const [
                    TextSpan(text:'• Tapit is a'),
                    TextSpan(text: ' two ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: 'player game.')
                  ]
                ),
              ),
              const SizedBox(height: 20,),
              Text(
                '• Each player has to constantly tap on the color on their side to fill out the whole screen with their color.',
                maxLines: 5,
                style: GoogleFonts.lato(
                  
                  fontSize: 20
                ),
              ),
              const SizedBox(height: 20,),
              Text(
                '• First player to fill out the screen with their color wins the game.',
                style: GoogleFonts.lato(
                  fontSize: 20
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}