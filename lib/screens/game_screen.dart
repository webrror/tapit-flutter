import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:tapit/constants/ai_difficulty.dart';
import 'package:tapit/constants/asset_constants.dart';
import 'package:tapit/constants/game_mode.dart';
import 'package:tapit/constants/game_theme.dart';
import 'package:tapit/constants/match_type.dart';
import 'package:tapit/constants/power_up_type.dart';
import 'package:tapit/constants/string_constants.dart';
import 'package:tapit/services/settings_service.dart';
import 'package:tapit/widgets/countdown_overlay.dart';
import 'package:tapit/widgets/tap_effect.dart';

class GameScreen extends StatefulWidget {
  final GameMode gameMode;
  final GameTheme gameTheme;
  final MatchType matchType;
  final bool isVsAI;
  final AIDifficulty aiDifficulty;
  final bool usePowerUps;

  const GameScreen({
    super.key,
    this.gameMode = GameMode.classic,
    this.gameTheme = GameTheme.classic,
    this.matchType = MatchType.single,
    this.isVsAI = false,
    this.aiDifficulty = AIDifficulty.medium,
    this.usePowerUps = false,
  });

  static const String routeName = '/game-screen';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  static const int _totalFlex = 100;
  static const int _flexStep = 3;
  static const int _targetWinFlex = 95;
  static const int _defaultTimeAttackSeconds = 30;
  static const double _orbRadius = 30.0;
  static const double _orbCollectRadius = 64.0;

  // --- Core game state ---
  int _orangeFlex = 50;
  int _purpleFlex = 50;
  int _orangeTaps = 0;
  int _purpleTaps = 0;
  int _orangeRoundWins = 0;
  int _purpleRoundWins = 0;
  int _currentRound = 1;
  int _remainingSeconds = _defaultTimeAttackSeconds;

  bool _isGameOver = false;
  bool _isCountingDown = true;
  bool _isRoundTransition = false;
  bool _isSuddenDeath = false;
  String _roundTransitionMessage = '';

  // --- Timers ---
  Timer? _aiTimer;
  Timer? _timeAttackTimer;

  // --- Animation controllers ---
  late final AnimationController _effectController;
  late final AnimationController _orbPulseController;
  final List<TapEffectItem> _tapEffects = [];

  // --- Power-up: orb ---
  PowerUpType? _orbType;
  Offset? _orbPosition;
  bool _orbOnOrangeSide = false;
  Timer? _orbSpawnTimer;
  Timer? _orbDespawnTimer;

  // --- Power-up: active effects ---
  bool _orangeFrozen = false;
  bool _purpleFrozen = false;
  Timer? _orangeFreezeTimer;
  Timer? _purpleFreezeTimer;
  int _orangeMultiplierLeft = 0;
  int _purpleMultiplierLeft = 0;

  // --- Power-up: banner toast ---
  String? _bannerText;
  Color? _bannerColor;
  Timer? _bannerTimer;

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

    _orbPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _stopAILoop();
    _stopTimeAttackTimer();
    _stopAllPowerUpTimers();
    _effectController.dispose();
    _orbPulseController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ─── Time Attack ──────────────────────────────────────────────────────────

  void _startTimeAttackTimer() {
    _stopTimeAttackTimer();
    if (widget.gameMode != GameMode.timeAttack) return;

    _remainingSeconds = _defaultTimeAttackSeconds;
    _timeAttackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isGameOver || _isCountingDown || _isRoundTransition) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          if (_remainingSeconds <= 5 && _remainingSeconds > 0) {
            SettingsService.instance.triggerHaptic(HapticType.medium);
          }
        }
        if (_remainingSeconds == 0) {
          _stopTimeAttackTimer();
          if (_orangeFlex > _purpleFlex) {
            _handleRoundWin(true, isKnockout: false);
          } else if (_purpleFlex > _orangeFlex) {
            _handleRoundWin(false, isKnockout: false);
          } else {
            _isSuddenDeath = true;
            SettingsService.instance.triggerHaptic(HapticType.heavy);
          }
        }
      });
    });
  }

  void _stopTimeAttackTimer() {
    _timeAttackTimer?.cancel();
    _timeAttackTimer = null;
  }

  // ─── AI Loop ──────────────────────────────────────────────────────────────

  void _startAILoop() {
    _stopAILoop();
    if (!widget.isVsAI) return;
    _scheduleNextAITap();
  }

  void _stopAILoop() {
    _aiTimer?.cancel();
    _aiTimer = null;
  }

  void _scheduleNextAITap() {
    if (!mounted || _isGameOver || _isCountingDown || _isRoundTransition) return;

    final random = math.Random();
    int minMs = widget.aiDifficulty.minIntervalMs;
    int maxMs = widget.aiDifficulty.maxIntervalMs;

    if (widget.aiDifficulty == AIDifficulty.insane && _orangeFlex < 35) {
      minMs = (minMs * 0.7).toInt();
      maxMs = (maxMs * 0.7).toInt();
    }

    final interval = minMs + random.nextInt(math.max(1, maxMs - minMs + 1));
    _aiTimer = Timer(Duration(milliseconds: interval), () {
      if (!mounted || _isGameOver || _isCountingDown || _isRoundTransition) return;

      final screenSize = MediaQuery.of(context).size;
      final currentOrangeHeight = screenSize.height * (_orangeFlex / 100);

      Offset tapPos;
      // AI actively goes for orbs on its side
      if (widget.usePowerUps &&
          _orbType != null &&
          _orbOnOrangeSide &&
          _orbPosition != null &&
          random.nextDouble() < 0.4) {
        tapPos = _orbPosition! +
            Offset(random.nextDouble() * 16 - 8, random.nextDouble() * 16 - 8);
      } else {
        tapPos = Offset(
          40.0 + random.nextDouble() * math.max(10.0, screenSize.width - 80.0),
          40.0 + random.nextDouble() * math.max(10.0, currentOrangeHeight - 60.0),
        );
      }

      onTapOrange(tapPos);
      _scheduleNextAITap();
    });
  }

  // ─── Power-up: Orb Lifecycle ──────────────────────────────────────────────

  void _startOrbCycle() {
    if (!widget.usePowerUps) return;
    _scheduleNextOrb();
  }

  void _scheduleNextOrb() {
    _orbSpawnTimer?.cancel();
    if (!mounted || _isGameOver) return;
    final delayMs = 5000 + math.Random().nextInt(4000); // 5–9 s
    _orbSpawnTimer = Timer(Duration(milliseconds: delayMs), _spawnOrb);
  }

  void _spawnOrb() {
    if (!mounted || _isGameOver || _isCountingDown || _isRoundTransition) {
      _scheduleNextOrb();
      return;
    }

    final random = math.Random();
    final type = PowerUpType.values[random.nextInt(PowerUpType.values.length)];
    final onOrangeSide = random.nextBool();
    final screenSize = MediaQuery.of(context).size;
    final orangeZoneH = screenSize.height * _orangeFlex / 100;

    double orbX = 80 + random.nextDouble() * (screenSize.width - 160);
    double orbY;

    if (onOrangeSide) {
      final minY = _orbRadius + 60;
      final maxY = math.max(minY + 10, orangeZoneH - _orbRadius - 20);
      orbY = minY + random.nextDouble() * (maxY - minY);
    } else {
      final zoneStart = orangeZoneH + 4;
      final minY = zoneStart + _orbRadius + 20;
      final maxY = math.max(minY + 10, screenSize.height - _orbRadius - 60);
      orbY = minY + random.nextDouble() * (maxY - minY);
    }

    setState(() {
      _orbType = type;
      _orbPosition = Offset(orbX, orbY);
      _orbOnOrangeSide = onOrangeSide;
    });

    // Auto-despawn after 5 s
    _orbDespawnTimer?.cancel();
    _orbDespawnTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _orbType = null;
          _orbPosition = null;
        });
      }
      _scheduleNextOrb();
    });
  }

  void _clearOrb() {
    _orbDespawnTimer?.cancel();
    _orbDespawnTimer = null;
    _orbType = null;
    _orbPosition = null;
  }

  void _collectOrb(bool byOrange) {
    if (_orbType == null) return;
    final type = _orbType!;
    SettingsService.instance.triggerHaptic(HapticType.medium);
    setState(() => _clearOrb());
    _applyPowerUp(type, byOrange);
    _scheduleNextOrb();
  }

  void _applyPowerUp(PowerUpType type, bool toOrange) {
    switch (type) {
      case PowerUpType.doubleTap:
        setState(() {
          if (toOrange) {
            _orangeMultiplierLeft = 5;
          } else {
            _purpleMultiplierLeft = 5;
          }
        });
        _showBanner(
          toOrange
              ? '⚡ ${widget.gameTheme.player1Name}: 2× Tap Power!'
              : '⚡ ${widget.gameTheme.player2Name}: 2× Tap Power!',
          type.color,
        );
      case PowerUpType.freeze:
        // Freeze the OPPONENT
        if (toOrange) {
          _purpleFreezeTimer?.cancel();
          setState(() => _purpleFrozen = true);
          _purpleFreezeTimer = Timer(const Duration(milliseconds: 1500), () {
            if (mounted) setState(() => _purpleFrozen = false);
          });
          _showBanner(
            '❄ ${widget.gameTheme.player2Name} Frozen!',
            type.color,
          );
        } else {
          _orangeFreezeTimer?.cancel();
          setState(() => _orangeFrozen = true);
          _orangeFreezeTimer = Timer(const Duration(milliseconds: 1500), () {
            if (mounted) setState(() => _orangeFrozen = false);
          });
          _showBanner(
            '❄ ${widget.gameTheme.player1Name} Frozen!',
            type.color,
          );
        }
      case PowerUpType.blast:
        bool wonByBlast = false;
        setState(() {
          if (toOrange) {
            final newFlex = (_orangeFlex + 8).clamp(0, _totalFlex);
            _orangeFlex = newFlex;
            _purpleFlex = _totalFlex - newFlex;
          } else {
            final newFlex = (_purpleFlex + 8).clamp(0, _totalFlex);
            _purpleFlex = newFlex;
            _orangeFlex = _totalFlex - newFlex;
          }
          if (_orangeFlex >= _targetWinFlex) {
            _orangeFlex = _totalFlex;
            _purpleFlex = 0;
            wonByBlast = true;
          } else if (_purpleFlex >= _targetWinFlex) {
            _purpleFlex = _totalFlex;
            _orangeFlex = 0;
            wonByBlast = true;
          }
        });
        _showBanner(
          toOrange
              ? '💥 ${widget.gameTheme.player1Name}: +8% Blast!'
              : '💥 ${widget.gameTheme.player2Name}: +8% Blast!',
          type.color,
        );
        if (wonByBlast) {
          _handleRoundWin(toOrange, isKnockout: true);
        }
    }
  }

  void _showBanner(String text, Color color) {
    _bannerTimer?.cancel();
    setState(() {
      _bannerText = text;
      _bannerColor = color;
    });
    _bannerTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _bannerText = null);
    });
  }

  void _stopAllPowerUpTimers() {
    _orbSpawnTimer?.cancel();
    _orbDespawnTimer?.cancel();
    _orangeFreezeTimer?.cancel();
    _purpleFreezeTimer?.cancel();
    _bannerTimer?.cancel();
  }

  // ─── Match / Round Management ─────────────────────────────────────────────

  void resetFullMatch() {
    _stopAILoop();
    _stopTimeAttackTimer();
    _stopAllPowerUpTimers();
    setState(() {
      _orangeFlex = 50;
      _purpleFlex = 50;
      _orangeTaps = 0;
      _purpleTaps = 0;
      _orangeRoundWins = 0;
      _purpleRoundWins = 0;
      _currentRound = 1;
      _remainingSeconds = _defaultTimeAttackSeconds;
      _isSuddenDeath = false;
      _tapEffects.clear();
      _isGameOver = false;
      _isRoundTransition = false;
      _isCountingDown = true;
      // reset power-up state
      _orbType = null;
      _orbPosition = null;
      _orangeFrozen = false;
      _purpleFrozen = false;
      _orangeMultiplierLeft = 0;
      _purpleMultiplierLeft = 0;
      _bannerText = null;
    });
  }

  void _nextRound() {
    _stopAILoop();
    _stopTimeAttackTimer();
    _stopAllPowerUpTimers();
    setState(() {
      _orangeFlex = 50;
      _purpleFlex = 50;
      _remainingSeconds = _defaultTimeAttackSeconds;
      _isSuddenDeath = false;
      _tapEffects.clear();
      _isGameOver = false;
      _isRoundTransition = false;
      _isCountingDown = true;
      _orbType = null;
      _orbPosition = null;
      _orangeFrozen = false;
      _purpleFrozen = false;
      _orangeMultiplierLeft = 0;
      _purpleMultiplierLeft = 0;
      _bannerText = null;
    });
  }

  void _addTapEffect(Offset position, Color color) {
    setState(() {
      _tapEffects.add(
        TapEffectItem(
          position: position,
          color: color,
          createdAt: DateTime.now(),
          particles: ParticleSpark.generate(7),
        ),
      );
      final cutoff = DateTime.now().subtract(const Duration(milliseconds: 400));
      _tapEffects.removeWhere((e) => e.createdAt.isBefore(cutoff));
    });
  }

  void _handleRoundWin(bool orangeWon, {bool isKnockout = true}) {
    _stopAILoop();
    _stopTimeAttackTimer();
    _stopAllPowerUpTimers();
    _isGameOver = true;
    SettingsService.instance.triggerHaptic(HapticType.heavy);

    if (orangeWon) {
      _orangeRoundWins++;
    } else {
      _purpleRoundWins++;
    }

    final isMatchOver = _orangeRoundWins >= widget.matchType.winsNeeded ||
        _purpleRoundWins >= widget.matchType.winsNeeded;

    if (isMatchOver) {
      String winnerText;
      if (widget.isVsAI) {
        winnerText = orangeWon ? "AI Bot Won!" : "You Won!";
      } else {
        winnerText = orangeWon
            ? "${widget.gameTheme.player1Name} Won!"
            : "${widget.gameTheme.player2Name} Won!";
      }
      showWinnerDialog(winnerText, isKnockout: isKnockout);
    } else {
      String winnerName = widget.isVsAI
          ? (orangeWon ? "AI Bot" : "You")
          : (orangeWon
              ? widget.gameTheme.player1Name
              : widget.gameTheme.player2Name);

      setState(() {
        _isRoundTransition = true;
        _roundTransitionMessage =
            "Round $_currentRound: $winnerName Wins!${isKnockout ? '' : ' (Time Up)'}";
      });

      Future.delayed(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        setState(() => _currentRound++);
        _nextRound();
      });
    }
  }

  void showWinnerDialog(String winnerText, {bool isKnockout = true}) {
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
              const SizedBox(height: 6),
              if (widget.gameMode == GameMode.timeAttack)
                Text(
                  isKnockout
                      ? "⚡ Knockout Victory!"
                      : "⏱ Final Territory: ${widget.gameTheme.player1Name} $_orangeFlex% • ${widget.gameTheme.player2Name} $_purpleFlex%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: widget.gameTheme.player1Color,
                  ),
                ),
              const SizedBox(height: 8),
              if (widget.matchType.totalRounds > 1) ...[
                Text(
                  widget.isVsAI
                      ? "Match Score: $_purpleRoundWins – $_orangeRoundWins (You – AI)"
                      : "Match Score: $_orangeRoundWins – $_purpleRoundWins",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.gameTheme.player1Color,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                widget.isVsAI
                    ? "Your taps: $_purpleTaps  •  AI taps: $_orangeTaps"
                    : "${widget.gameTheme.player1Name}: $_orangeTaps taps  •  ${widget.gameTheme.player2Name}: $_purpleTaps taps",
                style: TextStyle(
                  fontSize: 13,
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
                    resetFullMatch();
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

  // ─── Tap Handlers ─────────────────────────────────────────────────────────

  void onTapOrange(Offset position) {
    if (_isGameOver || _isCountingDown || _isRoundTransition) return;
    if (_orangeFrozen) return;

    // Check orb collection
    if (widget.usePowerUps &&
        _orbType != null &&
        _orbOnOrangeSide &&
        _orbPosition != null &&
        (position - _orbPosition!).distance < _orbCollectRadius) {
      _collectOrb(true);
    }

    SettingsService.instance.triggerHaptic(HapticType.light);
    _addTapEffect(position, Colors.white);

    setState(() {
      _orangeTaps++;
      final step = _orangeMultiplierLeft > 0 ? _flexStep * 2 : _flexStep;
      if (_orangeMultiplierLeft > 0) _orangeMultiplierLeft--;
      final newFlex = (_orangeFlex + step).clamp(0, _totalFlex);
      _orangeFlex = newFlex;
      _purpleFlex = _totalFlex - newFlex;

      if (_isSuddenDeath) {
        _handleRoundWin(true, isKnockout: false);
      } else if (_orangeFlex >= _targetWinFlex) {
        _orangeFlex = _totalFlex;
        _purpleFlex = 0;
        _handleRoundWin(true, isKnockout: true);
      }
    });
  }

  void onTapPurple(Offset position) {
    if (_isGameOver || _isCountingDown || _isRoundTransition) return;
    if (_purpleFrozen) return;

    // Check orb collection
    if (widget.usePowerUps &&
        _orbType != null &&
        !_orbOnOrangeSide &&
        _orbPosition != null &&
        (position - _orbPosition!).distance < _orbCollectRadius) {
      _collectOrb(false);
    }

    SettingsService.instance.triggerHaptic(HapticType.light);
    _addTapEffect(position, Colors.white);

    setState(() {
      _purpleTaps++;
      final step = _purpleMultiplierLeft > 0 ? _flexStep * 2 : _flexStep;
      if (_purpleMultiplierLeft > 0) _purpleMultiplierLeft--;
      final newFlex = (_purpleFlex + step).clamp(0, _totalFlex);
      _purpleFlex = newFlex;
      _orangeFlex = _totalFlex - newFlex;

      if (_isSuddenDeath) {
        _handleRoundWin(false, isKnockout: false);
      } else if (_purpleFlex >= _targetWinFlex) {
        _purpleFlex = _totalFlex;
        _orangeFlex = 0;
        _handleRoundWin(false, isKnockout: true);
      }
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isMultiRound = widget.matchType.totalRounds > 1;
    final p1Label = widget.isVsAI
        ? "BOT (${widget.aiDifficulty.title.toUpperCase()})"
        : "PLAYER 1 (${widget.gameTheme.player1Name.toUpperCase()})";
    final p2Label = widget.isVsAI
        ? "YOU"
        : "PLAYER 2 (${widget.gameTheme.player2Name.toUpperCase()})";

    final screenSize = MediaQuery.of(context).size;
    final orangeZoneH = screenSize.height * _orangeFlex / 100;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            // ── Split Playfield ──────────────────────────────────────────
            Column(
              children: [
                // Orange / P1 Zone
                if (_orangeFlex > 0)
                  Expanded(
                    flex: _orangeFlex,
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (e) {
                        if (!widget.isVsAI) onTapOrange(e.position);
                      },
                      child: Container(
                        color: widget.gameTheme.player1Color,
                        width: double.infinity,
                        height: double.infinity,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 6.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Transform.rotate(
                                angle: math.pi,
                                child: _PlayerStatusBadge(
                                  playerName: p1Label,
                                  percentage: _orangeFlex,
                                  roundWins: _orangeRoundWins,
                                  winsNeeded: widget.matchType.winsNeeded,
                                  isMultiRound: isMultiRound,
                                  currentRound: _currentRound,
                                  accentColor: Colors.white,
                                  multiplierLeft: _orangeMultiplierLeft,
                                  frozen: _orangeFrozen,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Divider with Time Attack clock
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(height: 4, color: Colors.white),
                    if (widget.gameMode == GameMode.timeAttack)
                      Positioned(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isSuddenDeath
                                ? Colors.redAccent
                                : (_remainingSeconds <= 5
                                    ? Colors.red.shade700
                                    : Colors.black87),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: (_isSuddenDeath || _remainingSeconds <= 5
                                        ? Colors.red
                                        : Colors.black)
                                    .withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isSuddenDeath
                                    ? Icons.bolt
                                    : Icons.timer_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isSuddenDeath
                                    ? "SUDDEN DEATH"
                                    : "00:${_remainingSeconds.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Rubik',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                // Purple / P2 Zone
                if (_purpleFlex > 0)
                  Expanded(
                    flex: _purpleFlex,
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (e) => onTapPurple(e.position),
                      child: Container(
                        color: widget.gameTheme.player2Color,
                        width: double.infinity,
                        height: double.infinity,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 6.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: _PlayerStatusBadge(
                                playerName: p2Label,
                                percentage: _purpleFlex,
                                roundWins: _purpleRoundWins,
                                winsNeeded: widget.matchType.winsNeeded,
                                isMultiRound: isMultiRound,
                                currentRound: _currentRound,
                                accentColor: Colors.white,
                                multiplierLeft: _purpleMultiplierLeft,
                                frozen: _purpleFrozen,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Freeze Overlays ──────────────────────────────────────────
            if (_orangeFrozen)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: orangeZoneH,
                child: IgnorePointer(
                  child: Container(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.28),
                    child: Center(
                      child: Transform.rotate(
                        angle: math.pi,
                        child: const Icon(
                          Icons.ac_unit_rounded,
                          color: Colors.white,
                          size: 52,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_purpleFrozen)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: screenSize.height - orangeZoneH - 4,
                child: IgnorePointer(
                  child: Container(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.28),
                    child: const Center(
                      child: Icon(
                        Icons.ac_unit_rounded,
                        color: Colors.white,
                        size: 52,
                      ),
                    ),
                  ),
                ),
              ),

            // ── Tap Particle Effects ─────────────────────────────────────
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

            // ── Power-up Orb ─────────────────────────────────────────────
            if (widget.usePowerUps &&
                _orbType != null &&
                _orbPosition != null)
              Positioned(
                left: _orbPosition!.dx - _orbRadius,
                top: _orbPosition!.dy - _orbRadius,
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _orbPulseController,
                    builder: (context, _) {
                      final t = _orbPulseController.value;
                      final scale = 0.82 + 0.36 * math.sin(t * math.pi * 2).abs();
                      final glow = 0.4 + 0.6 * math.sin(t * math.pi * 2).abs();
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: _orbRadius * 2,
                          height: _orbRadius * 2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.9),
                                _orbType!.color,
                              ],
                              stops: const [0.0, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _orbType!.color.withValues(alpha: glow),
                                blurRadius: 22,
                                spreadRadius: 8,
                              ),
                              BoxShadow(
                                color: _orbType!.color.withValues(alpha: 0.3),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _orbType!.icon,
                              color: Colors.white,
                              size: 22,
                              shadows: const [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // ── Power-up Banner Toast ────────────────────────────────────
            if (_bannerText != null)
              Positioned(
                left: 24,
                right: 24,
                top: screenSize.height / 2 - 28,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: _bannerColor?.withValues(alpha: 0.92) ??
                            Colors.black87,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (_bannerColor ?? Colors.black)
                                .withValues(alpha: 0.45),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Text(
                        _bannerText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Rubik',
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ── Round Transition Overlay ─────────────────────────────────
            if (_isRoundTransition)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: Container(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _roundTransitionMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.isVsAI
                                ? "Score: $_purpleRoundWins – $_orangeRoundWins (You – AI)"
                                : "Score: $_orangeRoundWins – $_purpleRoundWins",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ── 3-2-1 Countdown ──────────────────────────────────────────
            if (_isCountingDown && !_isRoundTransition)
              Positioned.fill(
                child: CountdownOverlay(
                  onComplete: () {
                    setState(() => _isCountingDown = false);
                    if (widget.gameMode == GameMode.timeAttack) {
                      _startTimeAttackTimer();
                    }
                    if (widget.isVsAI) _startAILoop();
                    if (widget.usePowerUps) _startOrbCycle();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Player Status Badge ──────────────────────────────────────────────────────

class _PlayerStatusBadge extends StatelessWidget {
  final String playerName;
  final int percentage;
  final int roundWins;
  final int winsNeeded;
  final bool isMultiRound;
  final int currentRound;
  final Color accentColor;
  final int multiplierLeft;
  final bool frozen;

  const _PlayerStatusBadge({
    required this.playerName,
    required this.percentage,
    required this.roundWins,
    required this.winsNeeded,
    required this.isMultiRound,
    required this.currentRound,
    required this.accentColor,
    this.multiplierLeft = 0,
    this.frozen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: frozen
            ? const Color(0xFF00E5FF).withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: frozen
              ? const Color(0xFF00E5FF).withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.3),
          width: frozen ? 2 : 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
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
              if (isMultiRound) ...[
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(winsNeeded, (index) {
                    final isWon = index < roundWins;
                    return Container(
                      margin: const EdgeInsets.only(left: 3),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isWon ? accentColor : Colors.white24,
                        border: Border.all(
                          color: isWon ? Colors.white : Colors.white38,
                          width: 1,
                        ),
                      ),
                    );
                  }),
                ),
              ],
              if (multiplierLeft > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD600).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '⚡ 2× ×$multiplierLeft',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
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
