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
  static const int _totalFlex = 100;
  static const int _flexStep = 3;
  static const int _targetWinFlex = 95;

  int _orangeFlex = 50;
  int _purpleFlex = 50;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
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
    setState(() {
      _orangeFlex = 50;
      _purpleFlex = 50;
      _isGameOver = false;
    });
  }

  void showWinnerDialog(String winnerText) {
    if (!mounted) return;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(AssetConstants.winner, height: 250),
              Text(
                winnerText,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
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
              const SizedBox(height: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(StringConstants.goBack),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onTapOrange() {
    if (_isGameOver) return;
    HapticFeedback.selectionClick();
    setState(() {
      final newOrangeFlex = (_orangeFlex + _flexStep).clamp(0, _totalFlex);
      _orangeFlex = newOrangeFlex;
      _purpleFlex = _totalFlex - newOrangeFlex;

      if (_orangeFlex >= _targetWinFlex) {
        _isGameOver = true;
        _orangeFlex = _totalFlex;
        _purpleFlex = 0;
        showWinnerDialog(StringConstants.orangeWon);
      }
    });
  }

  void onTapPurple() {
    if (_isGameOver) return;
    HapticFeedback.selectionClick();
    setState(() {
      final newPurpleFlex = (_purpleFlex + _flexStep).clamp(0, _totalFlex);
      _purpleFlex = newPurpleFlex;
      _orangeFlex = _totalFlex - newPurpleFlex;

      if (_purpleFlex >= _targetWinFlex) {
        _isGameOver = true;
        _purpleFlex = _totalFlex;
        _orangeFlex = 0;
        showWinnerDialog(StringConstants.purpleWon);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            if (_orangeFlex > 0)
              Expanded(
                flex: _orangeFlex,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) => onTapOrange(),
                  child: Container(
                    color: Colors.deepOrangeAccent,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            if (_purpleFlex > 0)
              Expanded(
                flex: _purpleFlex,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) => onTapPurple(),
                  child: Container(
                    color: Colors.deepPurpleAccent,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
