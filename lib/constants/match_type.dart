enum MatchType {
  single(1, 'Quick Match', '1 Round'),
  bestOfThree(3, 'Best of 3', 'First to 2 wins'),
  bestOfFive(5, 'Best of 5', 'First to 3 wins');

  final int totalRounds;
  final String title;
  final String subtitle;

  const MatchType(this.totalRounds, this.title, this.subtitle);

  int get winsNeeded => (totalRounds / 2).ceil();
}
