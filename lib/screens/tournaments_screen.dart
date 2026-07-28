import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tournament.dart';
import '../providers/tournament_providers.dart';
import 'tournament_details_screen.dart';

class TournamentsScreen extends ConsumerWidget {
  const TournamentsScreen({super.key});

  Future<void> showTournamentDialog(BuildContext context, WidgetRef ref, {Tournament? tournament}) async {
    final nameController = TextEditingController(text: tournament?.name ?? '');
    final locationController = TextEditingController(text: tournament?.location ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tournament == null ? "New Tournament" : "Edit Tournament"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Tournament Name")),
            const SizedBox(height: 12),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: "Location")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final db = ref.read(dbProvider);

              if (tournament == null) {
                await db.createTournament(Tournament(
                  name: nameController.text.trim(),
                  location: locationController.text.trim(),
                ));
              } else {
                await db.updateTournament(tournament.copyWith(
                  name: nameController.text.trim(),
                  location: locationController.text.trim(),
                ));
              }

              if (!context.mounted) return;
              Navigator.pop(context);
              ref.refresh(tournamentsProvider);
              ref.refresh(dashboardStatsProvider);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentsAsync = ref.watch(tournamentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Tournaments")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTournamentDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text("New Event"),
      ),
      body: tournamentsAsync.when(
        data: (tournaments) => tournaments.isEmpty
            ? const Center(child: Text("No tournaments created."))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tournaments.length,
                itemBuilder: (context, index) {
                  final tournament = tournaments[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xffD4AF37),
                        child: Icon(Icons.emoji_events, color: Colors.black),
                      ),
                      title: Text(tournament.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text("📍 ${tournament.location}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => showTournamentDialog(context, ref, tournament: tournament),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await ref.read(dbProvider).deleteTournament(tournament.id!);
                              ref.refresh(tournamentsProvider);
                              ref.refresh(dashboardStatsProvider);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TournamentDetailsScreen(tournament: tournament)),
                        );
                      },
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text("Error loading tournaments")),
      ),
    );
  }
}