class TournamentPlayer {
  final int? id;
  final int tournamentId;
  final int playerId;

  TournamentPlayer({
    this.id,
    required this.tournamentId,
    required this.playerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'playerId': playerId,
    };
  }

  factory TournamentPlayer.fromMap(Map<String, dynamic> map) {
    return TournamentPlayer(
      id: map['id'] as int?,
      tournamentId: map['tournamentId'] as int,
      playerId: map['playerId'] as int,
    );
  }
}