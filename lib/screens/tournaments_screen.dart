import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/tournament.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  List<Tournament> tournaments = [];

  @override
  void initState() {
    super.initState();
    loadTournaments();
  }

  Future loadTournaments() async {
    tournaments = await DatabaseHelper.instance.getTournaments();
    setState(() {});
  }

  Future addTournament() async {
    final nameController = TextEditingController();
    final locationController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Tournament"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Tournament Name",
              ),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Location",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final tournament = Tournament(
                name: nameController.text,
                location: locationController.text,
              );

              await DatabaseHelper.instance.createTournament(tournament);

              Navigator.pop(context);

              loadTournaments();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> editTournament(Tournament tournament) async {
    final nameController =
        TextEditingController(text: tournament.name);

    final locationController =
        TextEditingController(text: tournament.location);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Tournament"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Tournament Name",
              ),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Location",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedTournament = Tournament(
                id: tournament.id,
                name: nameController.text,
                location: locationController.text,
              );

              await DatabaseHelper.instance
                  .updateTournament(updatedTournament);

              Navigator.pop(context);

              loadTournaments();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Future<void> deleteTournament(int id) async {
    await DatabaseHelper.instance.deleteTournament(id);
    loadTournaments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tournaments"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTournament,
        child: const Icon(Icons.add),
      ),
      body: tournaments.isEmpty
          ? const Center(
              child: Text("No Tournaments Added"),
            )
          : ListView.builder(
              itemCount: tournaments.length,
              itemBuilder: (context, index) {
                final tournament = tournaments[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(tournament.name),
                    subtitle: Text(tournament.location),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            editTournament(tournament);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Delete Tournament"),
                                content: const Text(
                                  "Are you sure you want to delete this tournament?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );

                            if (shouldDelete == true) {
                              await deleteTournament(tournament.id!);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}