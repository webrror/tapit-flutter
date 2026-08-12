enum AIDifficulty {
  easy('Easy', 'Casual (3-4 taps/s)', 250, 310),
  medium('Medium', 'Challenging (6-7 taps/s)', 140, 175),
  hard('Hard', 'Furious (9-10 taps/s)', 95, 115),
  insane('Insane', 'Unbeatable (12+ taps/s)', 65, 85);

  final String title;
  final String description;
  final int minIntervalMs;
  final int maxIntervalMs;

  const AIDifficulty(
    this.title,
    this.description,
    this.minIntervalMs,
    this.maxIntervalMs,
  );
}
