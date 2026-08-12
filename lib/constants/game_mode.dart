import 'package:flutter/material.dart';

enum GameMode {
  classic(
    'Classic',
    'Tug-of-war: Push territory to 95% to win',
    Icons.sports_kabaddi_rounded,
  ),
  timeAttack(
    'Time Attack',
    '30-second frenzy: Most territory when time expires wins',
    Icons.timer_outlined,
  );

  final String title;
  final String description;
  final IconData icon;

  const GameMode(this.title, this.description, this.icon);
}
