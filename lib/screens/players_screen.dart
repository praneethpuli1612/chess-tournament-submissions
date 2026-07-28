import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../providers/tournament_providers.dart';

class PlayersScreen extends ConsumerWidget {
  const PlayersScreen({super.key});

  Future<void> showPlayerDialog(BuildContext context, WidgetRef ref, {Player? player}) async {
    final nameController = TextEditingController(text: player?.name ?? '');
    final ratingController = TextEditingController(text: player != null ? '${player.rating}' : '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(player == null ? "Add Player" : "Edit Player"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            const SizedBox(height: 12),
            TextField(
              controller: ratingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Elo Rating"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final rating = int.tryParse(ratingController.text) ?? 1200;
              final db = ref.read(dbProvider);

              if (player == null) {
                await db.createPlayer(Player(name: nameController.text.trim(), rating: rating));
              } else {
                await db.updatePlayer(player.copyWith(name: nameController.text.trim(), rating: rating));
              }

              if (!context.mounted) return;
              Navigator.pop(context);
              ref.refresh(playersProvider);
              ref.refresh(dashboardStatsProvider);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(playersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Player Roster")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showPlayerDialog(context, ref),
        icon: const Icon(Icons.person_add),
        label: const Text("Add Player"),
      ),
      body: playersAsync.when(
        data: (players) => players.isEmpty
            ? const Center(child: Text("No players added yet."))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xff0F172A),
                        child: Text(player.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("⭐ Rating: ${player.rating}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => showPlayerDialog(context, ref, player: player),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await ref.read(dbProvider).deletePlayer(player.id!);
                              ref.refresh(playersProvider);
                              ref.refresh(dashboardStatsProvider);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text("Failed to load players")),
      ),
    );
  }
}