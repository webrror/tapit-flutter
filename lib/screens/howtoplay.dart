import 'dart:math' as math;
import 'package:flutter/material.dart';

class HowToPlay extends StatefulWidget {
  const HowToPlay({super.key});
  static const String routeName = '/how-to-play';

  @override
  State<HowToPlay> createState() => _HowToPlayState();
}

class _HowToPlayState extends State<HowToPlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Finger animations
  late final Animation<double> _p1TapAnim;
  late final Animation<double> _p2TapAnim;
  // Territory fill
  late final Animation<double> _splitAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // P2 (bottom) taps at 0.1 → 0.4 s → 1.1 → 1.4, looping via controller
    _p2TapAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(0), weight: 30),
    ]).animate(_controller);

    // P1 (top) taps offset by half
    _p1TapAnim = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(0), weight: 20),
    ]).animate(_controller);

    // Territory split oscillates between 35%–65%
    _splitAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 0.38), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.38, end: 0.62), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.62, end: 0.5), weight: 20),
      TweenSequenceItem(tween: ConstantTween(0.5), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'How to Play',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Animated Mini Demo ─────────────────────────────────────
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      width: 240,
                      height: 360,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          final split = _splitAnim.value;
                          return Stack(
                            children: [
                              // Orange zone (P1 - top, rotated)
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: 360 * split,
                                child: Container(
                                  color: Colors.deepOrangeAccent,
                                  child: Center(
                                    child: Transform.rotate(
                                      angle: math.pi,
                                      child: _PlayerLabel(
                                        label: 'PLAYER 1',
                                        percent: (split * 100).round(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Purple zone (P2 - bottom)
                              Positioned(
                                top: 360 * split + 3,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  color: Colors.deepPurpleAccent,
                                  child: Center(
                                    child: _PlayerLabel(
                                      label: 'PLAYER 2',
                                      percent: ((1 - split) * 100).round(),
                                    ),
                                  ),
                                ),
                              ),

                              // Divider
                              Positioned(
                                top: 360 * split,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 3,
                                  color: Colors.white,
                                ),
                              ),

                              // P1 Finger (top, flipped)
                              Positioned(
                                top: 360 * split - 80 -
                                    (1 - _p1TapAnim.value) * 24,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Transform.rotate(
                                    angle: math.pi,
                                    child: _AnimatedFinger(
                                      progress: _p1TapAnim.value,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              // P2 Finger (bottom)
                              Positioned(
                                top: 360 * split + 3 + 20 +
                                    (1 - _p2TapAnim.value) * 24,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: _AnimatedFinger(
                                    progress: _p2TapAnim.value,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              // Tap ripple P1
                              if (_p1TapAnim.value > 0.3)
                                Positioned(
                                  top: 360 * split - 44,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: _TapRipple(
                                        progress: _p1TapAnim.value),
                                  ),
                                ),

                              // Tap ripple P2
                              if (_p2TapAnim.value > 0.3)
                                Positioned(
                                  top: 360 * split + 3 + 40,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: _TapRipple(
                                        progress: _p2TapAnim.value),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Rule Cards ─────────────────────────────────────────────
              _RuleCard(
                icon: Icons.people_alt_rounded,
                iconColor: colorScheme.primary,
                title: 'Two Player Game',
                body: 'Place the phone flat between two players — one on each side of the device.',
              ),
              const SizedBox(height: 12),
              _RuleCard(
                icon: Icons.touch_app_rounded,
                iconColor: Colors.deepOrangeAccent,
                title: 'Tap to Claim Territory',
                body: 'Each player must rapidly tap their colored zone to push the boundary into the opponent\'s half.',
              ),
              const SizedBox(height: 12),
              _RuleCard(
                icon: Icons.emoji_events_rounded,
                iconColor: Colors.amber,
                title: 'Fill the Screen to Win',
                body: 'First player to push their color to 95% of the screen wins the round!',
              ),
              const SizedBox(height: 12),
              _RuleCard(
                icon: Icons.auto_awesome_rounded,
                iconColor: Colors.purpleAccent,
                title: 'Game Modes & Power-ups',
                body: 'Try Best-of-3/5 matches, Time Attack (30 s), vs AI Bot, and enable Power-up Orbs for extra chaos!',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _PlayerLabel extends StatelessWidget {
  final String label;
  final int percent;
  const _PlayerLabel({required this.label, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          Text(
            '$percent%',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w900,
              fontSize: 20,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedFinger extends StatelessWidget {
  final double progress;
  final Color color;
  const _AnimatedFinger({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final scale = 1.0 - progress * 0.25;
    return Transform.scale(
      scale: scale,
      child: Icon(
        Icons.touch_app_rounded,
        color: color.withValues(alpha: 0.85 + progress * 0.15),
        size: 42,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}

class _TapRipple extends StatelessWidget {
  final double progress;
  const _TapRipple({required this.progress});

  @override
  Widget build(BuildContext context) {
    final size = 20 + progress * 36;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: (1 - progress) * 0.7),
          width: 2,
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  const _RuleCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
