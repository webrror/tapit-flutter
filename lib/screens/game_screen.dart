import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:tapit/constants/asset_constants.dart';
import 'package:tapit/constants/string_constants.dart';
import 'package:tapit/widgets/countdown_overlay.dart';
import 'package:tapit/widgets/tap_effect.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  static const String routeName = '/game-screen';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static const int _totalFlex = 100;
  static const int _flexStep = 3;
  static const int _targetWinFlex = 95;

  int _orangeFlex = 50;
  int _purpleFlex = 50;
  int _orangeTaps = 0;
  int _purpleTaps = 0;
  bool _isGameOver = false;
  bool _isCountingDown = true;

  late final AnimationController _effectController;
  final List<TapEffectItem> _tapEffects = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _effectController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _effectController.dispose();
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
      _orangeTaps = 0;
      _purpleTaps = 0;
      _tapEffects.clear();
      _isGameOver = false;
      _isCountingDown = true;
    });
  }

  void _addTapEffect(Offset globalPosition, Color color) {
    setState(() {
      _tapEffects.add(
        TapEffectItem(
          position: globalPosition,
          color: color,
          createdAt: DateTime.now(),
          particles: ParticleSpark.generate(7),
        ),
      );
      final cutoff = DateTime.now().subtract(const Duration(milliseconds: 400));
      _tapEffects.removeWhere((e) => e.createdAt.isBefore(cutoff));
    });
  }

  void showWinnerDialog(String winnerText) {
    if (!mounted) return;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(AssetConstants.winner, height: 220),
              Text(
                winnerText,
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Orange: $_orangeTaps taps  •  Purple: $_purpleTaps taps",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    resetGame();
                  },
                  child: const Text(
                    StringConstants.restart,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    StringConstants.goBack,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onTapOrange(Offset position) {
    if (_isGameOver || _isCountingDown) return;
    HapticFeedback.lightImpact();
    _addTapEffect(position, Colors.amberAccent);

    setState(() {
      _orangeTaps++;
      final newOrangeFlex = (_orangeFlex + _flexStep).clamp(0, _totalFlex);
      _orangeFlex = newOrangeFlex;
      _purpleFlex = _totalFlex - newOrangeFlex;

      if (_orangeFlex >= _targetWinFlex) {
        _isGameOver = true;
        _orangeFlex = _totalFlex;
        _purpleFlex = 0;
        HapticFeedback.heavyImpact();
        showWinnerDialog(StringConstants.orangeWon);
      }
    });
  }

  void onTapPurple(Offset position) {
    if (_isGameOver || _isCountingDown) return;
    HapticFeedback.lightImpact();
    _addTapEffect(position, Colors.cyanAccent);

    setState(() {
      _purpleTaps++;
      final newPurpleFlex = (_purpleFlex + _flexStep).clamp(0, _totalFlex);
      _purpleFlex = newPurpleFlex;
      _orangeFlex = _totalFlex - newPurpleFlex;

      if (_purpleFlex >= _targetWinFlex) {
        _isGameOver = true;
        _purpleFlex = _totalFlex;
        _orangeFlex = 0;
        HapticFeedback.heavyImpact();
        showWinnerDialog(StringConstants.purpleWon);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            // Split Playfield
            Column(
              children: [
                // Top Zone (Player 1 - Orange)
                if (_orangeFlex > 0)
                  Expanded(
                    flex: _orangeFlex,
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (e) => onTapOrange(e.position),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFF5722),
                              Color(0xFFFF7043),
                            ],
                          ),
                        ),
                        width: double.infinity,
                        height: double.infinity,
                        child: Center(
                          // Flipped 180° for Player 1 across the table
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Transform.rotate(
                                angle: math.pi,
                                child: _PlayerStatusBadge(
                                  playerName: "PLAYER 1",
                                  percentage: _orangeFlex,
                                  taps: _orangeTaps,
                                  accentColor: Colors.amberAccent,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Dividing Line with real-time dominance percentage
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

                // Bottom Zone (Player 2 - Purple)
                if (_purpleFlex > 0)
                  Expanded(
                    flex: _purpleFlex,
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (e) => onTapPurple(e.position),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF7E57C2),
                              Color(0xFF5E35B1),
                            ],
                          ),
                        ),
                        width: double.infinity,
                        height: double.infinity,
                        child: Center(
                          // Upright for Player 2
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: _PlayerStatusBadge(
                                playerName: "PLAYER 2",
                                percentage: _purpleFlex,
                                taps: _purpleTaps,
                                accentColor: Colors.cyanAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Live Particle & Ripple Effect Layer
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _effectController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: TapEffectPainter(
                        effects: _tapEffects,
                        animationValue: _effectController.value,
                      ),
                    );
                  },
                ),
              ),
            ),

            // 3-2-1 Countdown Overlay
            if (_isCountingDown)
              Positioned.fill(
                child: CountdownOverlay(
                  onComplete: () {
                    setState(() {
                      _isCountingDown = false;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlayerStatusBadge extends StatelessWidget {
  final String playerName;
  final int percentage;
  final int taps;
  final Color accentColor;

  const _PlayerStatusBadge({
    required this.playerName,
    required this.percentage,
    required this.taps,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            playerName,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            "$percentage%",
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w900,
              fontSize: 24,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
