import 'package:flutter/material.dart';

enum GameTheme {
  classic(
    'Classic',
    Colors.deepOrangeAccent,
    Colors.deepPurpleAccent,
    'Orange',
    'Purple',
  ),
  cyberpunk(
    'Cyberpunk',
    Color(0xFFFF007F),
    Color(0xFF00E5FF),
    'Neon Pink',
    'Electric Cyan',
  ),
  fireAndIce(
    'Fire & Ice',
    Color(0xFFFF3D00),
    Color(0xFF00B0FF),
    'Fire Red',
    'Ice Blue',
  ),
  emeraldGold(
    'Emerald & Gold',
    Color(0xFFFFB300),
    Color(0xFF00C853),
    'Gold',
    'Emerald',
  ),
  synthwave(
    'Synthwave',
    Color(0xFF8E24AA),
    Color(0xFF1E88E5),
    'Violet',
    'Cobalt',
  );

  final String title;
  final Color player1Color;
  final Color player2Color;
  final String player1Name;
  final String player2Name;

  const GameTheme(
    this.title,
    this.player1Color,
    this.player2Color,
    this.player1Name,
    this.player2Name,
  );
}
