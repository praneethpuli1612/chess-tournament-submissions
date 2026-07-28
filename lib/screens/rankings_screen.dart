import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tournament_providers.dart';

class RankingsScreen extends ConsumerWidget {
  const RankingsScreen({super.key});

  Widget _buildPodiumColumn({
    required String name,
    required int wins,
    required int place,
    required Color color,
    required double height,
    required IconData crown,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(crown, color: color, size: place == 1 ? 28 : 22),
        const SizedBox(height: 4),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xff0F172A),
            ),
          ),
        ),
        Text(
          "$wins Wins",
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        Container(
          width: 85,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              "#$place",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Leaderboard")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: db.getRankings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rankings = snapshot.data!;
          if (rankings.isEmpty) {
            return const Center(child: Text("No match scores recorded yet."));
          }

          final first = rankings.isNotEmpty ? rankings[0] : null;
          final second = rankings.length > 1 ? rankings[1] : null;
          final third = rankings.length > 2 ? rankings[2] : null;

          return Column(
            children: [
              // Visual Podium Section
              Container(
                padding: const EdgeInsets.only(top: 20, bottom: 0, left: 16, right: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(color: Colors.black45, blurRadius: 10),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 2nd Place (Silver)
                    if (second != null)
                      _buildPodiumColumn(
                        name: second['name'] as String,
                        wins: second['wins'] as int,
                        place: 2,
                        color: const Color(0xff64748B),
                        height: 90,
                        crown: Icons.workspace_premium_rounded,
                      )
                    else
                      const SizedBox(width: 85),

                    const SizedBox(width: 12),

                    // 1st Place (Gold)
                    if (first != null)
                      _buildPodiumColumn(
                        name: first['name'] as String,
                        wins: first['wins'] as int,
                        place: 1,
                        color: const Color(0xffD4AF37),
                        height: 125,
                        crown: Icons.emoji_events_rounded,
                      ),

                    const SizedBox(width: 12),

                    // 3rd Place (Bronze)
                    if (third != null)
                      _buildPodiumColumn(
                        name: third['name'] as String,
                        wins: third['wins'] as int,
                        place: 3,
                        color: const Color(0xffB45309),
                        height: 70,
                        crown: Icons.workspace_premium_rounded,
                      )
                    else
                      const SizedBox(width: 85),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Ranks 4+ List View
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: rankings.length > 3 ? rankings.length - 3 : 0,
                  itemBuilder: (context, index) {
                    final rank = rankings[index + 3];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xff0F172A).withOpacity(0.08),
                          child: Text(
                            "#${index + 4}",
                            style: const TextStyle(
                              color: Color(0xff0F172A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          rank['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xff0F172A).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${rank['wins']} Wins",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff0F172A),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}