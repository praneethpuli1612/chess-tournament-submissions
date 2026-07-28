import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../models/player.dart';
import '../models/tournament.dart';

final dbProvider = Provider((ref) => DatabaseHelper.instance);

final playersProvider = FutureProvider<List<Player>>((ref) async {
  return await ref.watch(dbProvider).getPlayers();
});

final tournamentsProvider = FutureProvider<List<Tournament>>((ref) async {
  return await ref.watch(dbProvider).getTournaments();
});

final dashboardStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final db = ref.watch(dbProvider);
  return {
    'players': await db.getPlayerCount(),
    'tournaments': await db.getTournamentCount(),
    'matches': await db.getMatchCount(),
    'winners': await db.getWinnerCount(),
  };
});