import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tapit/constants/asset_constants.dart';
import 'package:tapit/constants/match_type.dart';
import 'package:tapit/constants/string_constants.dart';
import 'package:tapit/screens/about.dart';
import 'package:tapit/screens/game_screen.dart';
import 'package:tapit/screens/howtoplay.dart';
import 'package:tapit/services/native.dart';
import 'package:tapit/widgets/glass_menu_button.dart';
import 'package:tapit/widgets/match_setup_sheet.dart';
import 'package:tapit/widgets/quick_settings_bar.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Ambient Background Glow Blobs ────────────────────────────
          Positioned(
            top: -60,
            left: -40,
            child: _GlowBlob(
              color: const Color(0xFFFF6D00)
                  .withValues(alpha: isDark ? 0.18 : 0.12),
              size: 260,
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: _GlowBlob(
              color: const Color(0xFF7C4DFF)
                  .withValues(alpha: isDark ? 0.22 : 0.14),
              size: 300,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            right: -40,
            child: _GlowBlob(
              color: const Color(0xFF00E5FF)
                  .withValues(alpha: isDark ? 0.10 : 0.08),
              size: 200,
            ),
          ),

          // ── Main Content ─────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top Header with Quick Settings Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _VersionPill(),
                      const QuickSettingsBar(),
                    ],
                  ),
                ),

                // Body (Responsive Layout)
                Expanded(
                  child: OrientationBuilder(
                    builder: (context, orientation) {
                      if (orientation == Orientation.landscape) {
                        return _buildLandscapeLayout(context);
                      } else {
                        return _buildPortraitLayout(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final btnWidth = math.min(width * 0.88, 340.0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            // Hero Animation & Title
            LottieBuilder.asset(
              AssetConstants.homeAnim,
              frameRate: FrameRate.max,
              alignment: Alignment.center,
              width: math.min(width * 0.65, 230.0),
            ),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFF6D00), Color(0xFF7C4DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                StringConstants.appName,
                style: TextStyle(
                  fontSize: 48,
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Modern Interactive Menu Buttons
            GlassMenuButton(
              title: StringConstants.quickPlay,
              subtitle: 'Instant 1v1 classic battle',
              icon: Icons.bolt_rounded,
              isPrimary: true,
              width: btnWidth,
              onTap: () => _startQuickPlay(context),
            ),
            GlassMenuButton(
              title: StringConstants.gameModes,
              subtitle: 'Custom rounds, bots & rules',
              icon: Icons.sports_esports_rounded,
              width: btnWidth,
              onTap: () => MatchSetupSheet.show(context),
            ),
            GlassMenuButton(
              title: StringConstants.howToPlay,
              subtitle: 'Interactive guide & rules',
              icon: Icons.menu_book_rounded,
              width: btnWidth,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HowToPlay()),
                );
              },
            ),
            GlassMenuButton(
              title: StringConstants.about,
              subtitle: 'Credits, links & source code',
              icon: Icons.info_outline_rounded,
              width: btnWidth,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const About()),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final btnWidth = math.min(width * 0.42, 340.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Hero Lottie & Title
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LottieBuilder.asset(
                  AssetConstants.homeAnim,
                  frameRate: FrameRate.max,
                  alignment: Alignment.center,
                  width: math.min(width * 0.25, 180.0),
                ),
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFF6D00), Color(0xFF7C4DFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    StringConstants.appName,
                    style: TextStyle(
                      fontSize: 44,
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Right: Action Buttons Scrollable
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GlassMenuButton(
                    title: StringConstants.quickPlay,
                    subtitle: 'Instant 1v1 classic battle',
                    icon: Icons.bolt_rounded,
                    isPrimary: true,
                    width: btnWidth,
                    onTap: () => _startQuickPlay(context),
                  ),
                  GlassMenuButton(
                    title: StringConstants.gameModes,
                    subtitle: 'Custom rounds, bots & rules',
                    icon: Icons.sports_esports_rounded,
                    width: btnWidth,
                    onTap: () => MatchSetupSheet.show(context),
                  ),
                  GlassMenuButton(
                    title: StringConstants.howToPlay,
                    subtitle: 'Interactive guide & rules',
                    icon: Icons.menu_book_rounded,
                    width: btnWidth,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HowToPlay()),
                      );
                    },
                  ),
                  GlassMenuButton(
                    title: StringConstants.about,
                    subtitle: 'Credits, links & source code',
                    icon: Icons.info_outline_rounded,
                    width: btnWidth,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const About()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.0)],
          stops: const [0.2, 1.0],
        ),
      ),
    );
  }
}

class _VersionPill extends StatefulWidget {
  const _VersionPill();

  @override
  State<_VersionPill> createState() => _VersionPillState();
}

class _VersionPillState extends State<_VersionPill> {
  String _version = 'v1.0.6';

  @override
  void initState() {
    super.initState();
    NativeService.getAppInfo().then((info) {
      if (info.version.isNotEmpty && mounted) {
        setState(() => _version = 'v${info.version}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.black.withValues(alpha: 0.05),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Container(
          //   width: 6,
          //   height: 6,
          //   decoration: const BoxDecoration(
          //     shape: BoxShape.circle,
          //     color: Color(0xFFFF6D00),
          //   ),
          // ),
          // const SizedBox(width: 6),
          Text(
            _version,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
