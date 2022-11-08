import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:tapit/screens/about.dart';
import 'package:tapit/screens/game_screen.dart';
import 'package:tapit/screens/howtoplay.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
          width: width,
          height: height,
          child: width > 600
              ? FittedBox(
                // fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      LottieBuilder.asset('assets/animations/homeanim.json'),
                      Text(
                        'Tap it',
                        style: GoogleFonts.rubikBubbles(fontSize: 50),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const GameScreen()),
                            );
                          },
                          child: GradientText(
                            'Start',
                            style: GoogleFonts.lato(fontSize: 20),
                            colors: const [
                              Colors.deepOrangeAccent, // 255 110 64 255
                              Colors.deepPurpleAccent // 124 77 255 255
                            ],
                          )),
                      const SizedBox(
                        height: 30,
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HowToPlay()),
                            );
                          },
                          child: GradientText(
                            'How to play',
                            style: GoogleFonts.lato(fontSize: 20),
                            colors: const [
                              Colors.deepOrangeAccent, // 255 110 64 255
                              Colors.deepPurpleAccent // 124 77 255 255
                            ],
                          )),
                      const SizedBox(
                        height: 30,
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const About()),
                            );
                          },
                          child: GradientText(
                            'About',
                            style: GoogleFonts.lato(fontSize: 20),
                            colors: const [
                              Colors.deepOrangeAccent, // 255 110 64 255
                              Colors.deepPurpleAccent // 124 77 255 255
                            ],
                          ))
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LottieBuilder.asset('assets/animations/homeanim.json'),
                    Text(
                      'Tap it',
                      style: GoogleFonts.rubikBubbles(fontSize: 50),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const GameScreen()),
                          );
                        },
                        child: GradientText(
                          'Start',
                          style: GoogleFonts.lato(fontSize: 20),
                          colors: const [
                            Colors.deepOrangeAccent, // 255 110 64 255
                            Colors.deepPurpleAccent // 124 77 255 255
                          ],
                        )),
                    const SizedBox(
                      height: 30,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HowToPlay()),
                          );
                        },
                        child: GradientText(
                          'How to play',
                          style: GoogleFonts.lato(fontSize: 20),
                          colors: const [
                            Colors.deepOrangeAccent, // 255 110 64 255
                            Colors.deepPurpleAccent // 124 77 255 255
                          ],
                        )),
                    const SizedBox(
                      height: 30,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const About()),
                          );
                        },
                        child: GradientText(
                          'About',
                          style: GoogleFonts.lato(fontSize: 20),
                          colors: const [
                            Colors.deepOrangeAccent, // 255 110 64 255
                            Colors.deepPurpleAccent // 124 77 255 255
                          ],
                        ))
                  ],
                ),
        ),
      ),
    );
  }
}
