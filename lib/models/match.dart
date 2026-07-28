class ChessMatch {
  final int? id;
  final int tournamentId;
  final int player1Id;
  final int player2Id;
  final int? winnerId;

  ChessMatch({
    this.id,
    required this.tournamentId,
    required this.player1Id,
    required this.player2Id,
    this.winnerId,
  });

  ChessMatch copyWith({
    int? id,
    int? tournamentId,
    int? player1Id,
    int? player2Id,
    int? winnerId,
  }) {
    return ChessMatch(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      winnerId: winnerId ?? this.winnerId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'player1Id': player1Id,
      'player2Id': player2Id,
      'winnerId': winnerId,
    };
  }

  factory ChessMatch.fromMap(Map<String, dynamic> map) {
    return ChessMatch(
      id: map['id'] as int?,
      tournamentId: map['tournamentId'] as int,
      player1Id: map['player1Id'] as int,
      player2Id: map['player2Id'] as int,
      winnerId: map['winnerId'] as int?,
    );
  }
}