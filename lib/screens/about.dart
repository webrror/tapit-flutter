import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tapit/constants/asset_constants.dart';
import 'package:tapit/constants/string_constants.dart';
import 'package:tapit/services/native.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  const About({super.key});
  static const String routeName = '/about';

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  AppInfo appInfo = AppInfo(appName: '', version: '');

  static const _githubUrl = 'https://github.com/webrror/tapit-flutter';
  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.rejie.tapit';
  static const _appStoreUrl =
      'https://apps.apple.com/us/app/tapit-2-player-battle/id6801258455';
  static const _shareText =
      'Try Tapit - the two-player tap battle game! 🎮\n\n'
      'App Store: $_appStoreUrl\n'
      'Google Play: $_playStoreUrl';
  // ──────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    NativeService.getAppInfo().then((value) {
      setState(() => appInfo = value);
    });
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  Future<void> _shareApp() async {
    await Share.share(_shareText);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── App Identity Block ────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          AssetConstants.appIcon,
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      appInfo.appName.isNotEmpty
                          ? appInfo.appName
                          : StringConstants.appName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (appInfo.version.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Version ${appInfo.version}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'The ultimate two-player tap battle',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Action Cards ──────────────────────────────────────────
              _SectionLabel(label: 'Get It'),
              const SizedBox(height: 8),

              _ActionTile(
                icon: Icons.android_rounded,
                iconColor: const Color(0xFF3DDC84),
                title: 'Rate on Google Play',
                subtitle: 'Leave a review & help others discover Tapit',
                onTap: () => _launch(_playStoreUrl),
              ),
              const SizedBox(height: 8),
              _ActionTile(
                icon: Icons.apple_rounded,
                iconColor: colorScheme.onSurface,
                title: 'Rate on App Store',
                subtitle: 'Leave a review & help others discover Tapit',
                onTap: () => _launch(_appStoreUrl),
              ),

              const SizedBox(height: 20),
              _SectionLabel(label: 'Share'),
              const SizedBox(height: 8),

              _ActionTile(
                icon: Icons.share_rounded,
                iconColor: colorScheme.primary,
                title: 'Share App with Friends',
                subtitle: 'Spread the tap battle madness 🎮',
                onTap: _shareApp,
              ),

              const SizedBox(height: 20),
              _SectionLabel(label: 'Developer'),
              const SizedBox(height: 8),

              _ActionTile(
                icon: Icons.code_rounded,
                iconColor: Colors.deepOrangeAccent,
                title: 'GitHub Repository',
                subtitle: 'View source, report bugs, or contribute',
                onTap: () => _launch(_githubUrl),
              ),

              const SizedBox(height: 20),
              _SectionLabel(label: 'Legal'),
              const SizedBox(height: 8),

              _ActionTile(
                icon: Icons.description_rounded,
                iconColor: colorScheme.onSurfaceVariant,
                title: 'Open-Source Licenses',
                subtitle: 'Third-party library attributions',
                onTap: () => showLicensePage(
                  context: context,
                  applicationName:
                      appInfo.appName.isNotEmpty ? appInfo.appName : 'Tapit',
                  applicationVersion: appInfo.version,
                  applicationIcon: Image.asset(
                    AssetConstants.appIcon,
                    height: 50,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Footer ─────────────────────────────────────────────────
              Center(
                child: Text(
                  'Made with ❤️ and too many taps',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared Helpers ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.45 : 1.0,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
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
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!disabled)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 14,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
