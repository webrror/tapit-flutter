import 'package:flutter/material.dart';
import 'package:tapit/constants/ai_difficulty.dart';
import 'package:tapit/constants/game_mode.dart';
import 'package:tapit/constants/game_theme.dart';
import 'package:tapit/constants/match_type.dart';
import 'package:tapit/screens/game_screen.dart';

class MatchSetupSheet extends StatefulWidget {
  const MatchSetupSheet({super.key});

  static Future<void> show(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 540),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // In landscape the sheet needs an explicit max height or it expands to
        // full screen height, leaving empty space. We use a fraction of the
        // available height so the sheet can still scroll.
        if (isLandscape) {
          final maxH = MediaQuery.of(context).size.height * 0.9;
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: const MatchSetupSheet(),
          );
        }
        return const MatchSetupSheet();
      },
    );
  }

  @override
  State<MatchSetupSheet> createState() => _MatchSetupSheetState();
}

class _MatchSetupSheetState extends State<MatchSetupSheet> {
  GameMode _selectedMode = GameMode.classic;
  GameTheme _selectedTheme = GameTheme.classic;
  bool _isVsAI = false;
  AIDifficulty _selectedDifficulty = AIDifficulty.medium;
  MatchType _selectedType = MatchType.bestOfThree;
  bool _usePowerUps = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Game Setup",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 14),

              // Game Mode (Classic vs Time Attack)
              SegmentedButton<GameMode>(
                segments: GameMode.values.map((mode) {
                  return ButtonSegment<GameMode>(
                    value: mode,
                    icon: Icon(mode.icon, size: 18),
                    label: Text(mode.title),
                  );
                }).toList(),
                selected: {_selectedMode},
                onSelectionChanged: (Set<GameMode> newSelection) {
                  setState(() {
                    _selectedMode = newSelection.first;
                  });
                },
              ),

              const SizedBox(height: 12),

              // Player Mode Toggle (2 Players vs Solo AI)
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: false,
                    icon: Icon(Icons.people_alt_rounded, size: 18),
                    label: Text("2 Players"),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    icon: Icon(Icons.smart_toy_rounded, size: 18),
                    label: Text("vs AI Bot"),
                  ),
                ],
                selected: {_isVsAI},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _isVsAI = newSelection.first;
                  });
                },
              ),

              // AI Difficulty Selector (Visible only when vs AI is selected)
              if (_isVsAI) ...[
                const SizedBox(height: 14),
                Text(
                  "AI Difficulty",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: AIDifficulty.values.map((difficulty) {
                    final isSelected = _selectedDifficulty == difficulty;
                    return ChoiceChip(
                      label: Text(difficulty.title),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedDifficulty = difficulty);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 14),
              Text(
                "Color Theme",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: GameTheme.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final themeItem = GameTheme.values[index];
                    final isSelected = _selectedTheme == themeItem;
                    return ChoiceChip(
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedTheme = themeItem);
                        }
                      },
                      avatar: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [themeItem.player1Color, themeItem.player2Color],
                          ),
                          border: Border.all(color: Colors.white70, width: 1),
                        ),
                      ),
                      label: Text(themeItem.title),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),
              Text(
                "Match Length",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),

              // Match Type Options
              ...MatchType.values.map((type) {
                final isSelected = _selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant.withValues(alpha: 0.6),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => setState(() => _selectedType = type),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.surfaceContainerHighest,
                              ),
                              child: Center(
                                child: Text(
                                  "${type.totalRounds}",
                                  style: TextStyle(
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    type.title,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    type.subtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: isSelected
                                          ? colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: colorScheme.primary, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 14),
              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                color: _usePowerUps
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: _usePowerUps
                        ? colorScheme.primary
                        : colorScheme.outlineVariant.withValues(alpha: 0.6),
                    width: _usePowerUps ? 2 : 1,
                  ),
                ),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  title: Text(
                    '⚡ Power-ups & Frenzy Mode',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _usePowerUps
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Tap glowing orbs for 2× boost, Freeze & Blasts!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: _usePowerUps
                          ? colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: _usePowerUps,
                  onChanged: (v) => setState(() => _usePowerUps = v),
                ),
              ),

              const SizedBox(height: 16),

              // Start Battle Button
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(
                        gameMode: _selectedMode,
                        gameTheme: _selectedTheme,
                        matchType: _selectedType,
                        isVsAI: _isVsAI,
                        aiDifficulty: _selectedDifficulty,
                        usePowerUps: _usePowerUps,
                      ),
                    ),
                  );
                },
                child: Text(
                  _selectedMode == GameMode.timeAttack
                      ? (_isVsAI ? "Start 30s Time Attack (vs AI)" : "Start 30s Time Attack")
                      : (_isVsAI ? "Battle AI (${_selectedDifficulty.title})" : "Start 2-Player Battle"),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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
