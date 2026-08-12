import 'package:flutter/material.dart';
import 'package:tapit/constants/asset_constants.dart';
import 'package:tapit/constants/string_constants.dart';
import 'package:tapit/constants/match_type.dart';
import 'package:tapit/screens/about.dart';
import 'package:tapit/screens/game_screen.dart';
import 'package:tapit/screens/howtoplay.dart';
import 'package:lottie/lottie.dart';
import 'package:tapit/widgets/gradient_text_button.dart';
import 'package:tapit/widgets/match_setup_sheet.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  static const String routeName = '/';

  void _startQuickPlay(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GameScreen(
          matchType: MatchType.single,
          isVsAI: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      extendBodyBehindAppBar: true,
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return SafeArea(
              top: false,
              child: SizedBox(
                width: width,
                height: height,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 100,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        LottieBuilder.asset(
                          AssetConstants.homeAnim,
                          frameRate: FrameRate.max,
                          alignment: Alignment.center,
                          width: width * 0.25,
                        ),
                        Text(
                          StringConstants.appName,
                          style: TextStyle(fontSize: 50, fontFamily: 'Rubik'),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        CommonGradientTextButton(
                          text: StringConstants.quickPlay,
                          onTap: () => _startQuickPlay(context),
                        ),
                        CommonGradientTextButton(
                          text: StringConstants.gameModes,
                          onTap: () => MatchSetupSheet.show(context),
                        ),
                        CommonGradientTextButton(
                          text: StringConstants.howToPlay,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HowToPlay()),
                            );
                          },
                        ),
                        CommonGradientTextButton(
                          text: StringConstants.about,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const About()),
                            );
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          } else {
            return SizedBox(
              width: width,
              height: height,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 40,
                  children: [
                    Column(
                      children: [
                        LottieBuilder.asset(
                          AssetConstants.homeAnim,
                          frameRate: FrameRate.max,
                          alignment: Alignment.center,
                          width: width * 0.85,
                        ),
                        const Text(
                          StringConstants.appName,
                          style: TextStyle(fontSize: 50, fontFamily: 'Rubik'),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8,
                      children: [
                        CommonGradientTextButton(
                          text: StringConstants.quickPlay,
                          onTap: () => _startQuickPlay(context),
                        ),
                        CommonGradientTextButton(
                          text: StringConstants.gameModes,
                          onTap: () => MatchSetupSheet.show(context),
                        ),
                        CommonGradientTextButton(
                          text: StringConstants.howToPlay,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HowToPlay()),
                            );
                          },
                        ),
                        CommonGradientTextButton(
                          text: StringConstants.about,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const About()),
                            );
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
