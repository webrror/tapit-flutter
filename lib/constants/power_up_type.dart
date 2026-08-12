import 'package:flutter/material.dart';

enum PowerUpType {
  doubleTap(
    '2×',
    '2x Tap Power!',
    'Next 5 taps count double!',
    Color(0xFFFFD600),
    Icons.flash_on_rounded,
  ),
  freeze(
    '❄',
    'Freeze!',
    'Opponent frozen for 1.5 seconds!',
    Color(0xFF00E5FF),
    Icons.ac_unit_rounded,
  ),
  blast(
    '💥',
    'Territory Blast!',
    '+8% instant territory push!',
    Color(0xFFFF6D00),
    Icons.local_fire_department_rounded,
  );

  final String symbol;
  final String title;
  final String description;
  final Color color;
  final IconData icon;

  const PowerUpType(
    this.symbol,
    this.title,
    this.description,
    this.color,
    this.icon,
  );
}
