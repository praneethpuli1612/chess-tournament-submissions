import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tournament_providers.dart';
import 'players_screen.dart';
import 'rankings_screen.dart';
import 'tournaments_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Widget _buildStatCard(IconData icon, Color color, String title, int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                Text(
                  "$value",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xff64748B),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xff0F172A),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(color: Color(0xff64748B), fontSize: 13),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
        ),
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          ref.refresh(dashboardStatsProvider);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chess Tournament Platform"),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(dashboardStatsProvider),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xff0F172A),
                    Color(0xff1E293B),
                    Color(0xff334155),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff0F172A).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Color(0xffD4AF37),
                          size: 32,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xffD4AF37).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xffD4AF37)),
                        ),
                        child: const Text(
                          "PRO EDITION",
                          style: TextStyle(
                            color: Color(0xffD4AF37),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Tournament Hub",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Manage players, automated pairings & live standings.",
                    style: TextStyle(color: Color(0xff94A3B8), fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            statsAsync.when(
              data: (stats) => Column(
                children: [
                  Row(children: [
                    _buildStatCard(Icons.people_alt_rounded, const Color(0xff2563EB), "PLAYERS", stats['players'] ?? 0),
                    const SizedBox(width: 14),
                    _buildStatCard(Icons.emoji_events_rounded, const Color(0xffD97706), "EVENTS", stats['tournaments'] ?? 0),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    _buildStatCard(Icons.sports_esports_rounded, const Color(0xff059669), "MATCHES", stats['matches'] ?? 0),
                    const SizedBox(width: 14),
                    _buildStatCard(Icons.military_tech_rounded, const Color(0xff7C3AED), "WINNERS", stats['winners'] ?? 0),
                  ]),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text("Error loading stats"),
            ),
            const SizedBox(height: 24),

            const Text(
              "Management Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff0F172A),
              ),
            ),
            const SizedBox(height: 14),

            _buildMenuCard(
              context,
              ref,
              icon: Icons.people_outline_rounded,
              color: const Color(0xff2563EB),
              title: "Player Directory",
              subtitle: "Register players and manage Elo ratings",
              page: const PlayersScreen(),
            ),
            _buildMenuCard(
              context,
              ref,
              icon: Icons.emoji_events_outlined,
              color: const Color(0xffD97706),
              title: "Tournaments",
              subtitle: "Create events and generate pairings",
              page: const TournamentsScreen(),
            ),
            _buildMenuCard(
              context,
              ref,
              icon: Icons.leaderboard_rounded,
              color: const Color(0xff059669),
              title: "Leaderboard & Rankings",
              subtitle: "View 1st, 2nd, and 3rd place podium standings",
              page: const RankingsScreen(),
            ),
          ],
        ),
      ),
    );
  }
}