class Ranking {
  final String playerName;
  final int wins;

  Ranking({
    required this.playerName,
    required this.wins,
  });

  factory Ranking.fromMap(Map<String, dynamic> map) {
    return Ranking(
      playerName: map['name'] as String? ?? 'Unknown Player',
      wins: map['wins'] as int? ?? 0,
    );
  }
}