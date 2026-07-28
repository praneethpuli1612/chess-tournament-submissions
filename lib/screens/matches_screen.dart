import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../providers/tournament_providers.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  final int tournamentId;

  const MatchesScreen({super.key, required this.tournamentId});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  List<ChessMatch> matches = [];
  List<Player> players = [];

  @override
  void initState() {
    super.initState();
    loadMatches();
  }

  Future<void> loadMatches() async {
    final db = ref.read(dbProvider);
    matches = await db.getMatches(widget.tournamentId);
    players = await db.getPlayers();
    if (mounted) setState(() {});
  }

  Player? getPlayer(int id) {
    return players.firstWhereOrNull((p) => p.id == id);
  }

  Future<void> selectWinner(ChessMatch match, Player p1, Player p2) async {
    final winnerId = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: Color(0xffD4AF37)),
            SizedBox(width: 10),
            Text("Select Match Winner"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: const Color(0xff2563EB).withOpacity(0.08),
              leading: CircleAvatar(child: Text(p1.name[0])),
              title: Text(p1.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Rating: ${p1.rating}"),
              onTap: () => Navigator.pop(context, p1.id),
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: const Color(0xff059669).withOpacity(0.08),
              leading: CircleAvatar(child: Text(p2.name[0])),
              title: Text(p2.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Rating: ${p2.rating}"),
              onTap: () => Navigator.pop(context, p2.id),
            ),
          ],
        ),
      ),
    );

    if (winnerId != null) {
      await ref.read(dbProvider).updateWinner(match.id!, winnerId);
      loadMatches();
      ref.refresh(dashboardStatsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tournament Matches")),
      body: matches.isEmpty
          ? const Center(child: Text("No matches generated yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                final p1 = getPlayer(match.player1Id);
                final p2 = getPlayer(match.player2Id);
                final winner = match.winnerId != null ? getPlayer(match.winnerId!) : null;

                if (p1 == null || p2 == null) return const SizedBox();

                final isP1Winner = match.winnerId == p1.id;
                final isP2Winner = match.winnerId == p2.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: winner != null ? const Color(0xffD4AF37) : const Color(0xffE2E8F0),
                      width: winner != null ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xff0F172A).withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "ROUND MATCH #${index + 1}",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0F172A),
                              ),
                            ),
                          ),
                          if (winner != null)
                            const Row(
                              children: [
                                Icon(Icons.emoji_events, color: Color(0xffD4AF37), size: 16),
                                SizedBox(width: 4),
                                Text(
                                  "FINISHED",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xffD4AF37),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Player VS Player Layout
                      Row(
                        children: [
                          // Player 1
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isP1Winner ? const Color(0xffD4AF37) : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 26,
                                    backgroundColor: const Color(0xff2563EB).withOpacity(0.15),
                                    child: Text(
                                      p1.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xff2563EB),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  p1.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Text(
                                  "⭐ ${p1.rating}",
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),

                          // VS Badge
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xff0F172A),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Text(
                              "VS",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          // Player 2
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isP2Winner ? const Color(0xffD4AF37) : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 26,
                                    backgroundColor: const Color(0xff059669).withOpacity(0.15),
                                    child: Text(
                                      p2.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xff059669),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  p2.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Text(
                                  "⭐ ${p2.rating}",
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: winner == null ? const Color(0xff0F172A) : const Color(0xffF1F5F9),
                            foregroundColor: winner == null ? Colors.white : const Color(0xff0F172A),
                            elevation: winner == null ? 2 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => selectWinner(match, p1, p2),
                          icon: const Icon(Icons.flag_rounded, size: 18),
                          label: Text(
                            winner == null ? "Select Winner" : "Change Winner (${winner.name})",
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}