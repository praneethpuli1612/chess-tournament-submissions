import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/player.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  List<Player> players = [];

  @override
  void initState() {
    super.initState();
    loadPlayers();
  }

  Future loadPlayers() async {
    players = await DatabaseHelper.instance.getPlayers();
    setState(() {});
  }

  Future addPlayer() async {
    final nameController = TextEditingController();
    final ratingController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Player"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Player Name",
              ),
            ),
            TextField(
              controller: ratingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Rating",
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
              final player = Player(
                name: nameController.text,
                rating: int.parse(ratingController.text),
              );

              await DatabaseHelper.instance.createPlayer(player);

              Navigator.pop(context);

              loadPlayers();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> editPlayer(Player player) async {
  final nameController = TextEditingController(text: player.name);
  final ratingController =
      TextEditingController(text: player.rating.toString());

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Edit Player"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Player Name",
            ),
          ),
          TextField(
            controller: ratingController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Rating",
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
            final updatedPlayer = Player(
              id: player.id,
              name: nameController.text,
              rating: int.parse(ratingController.text),
            );

            await DatabaseHelper.instance.updatePlayer(updatedPlayer);

            Navigator.pop(context);

            loadPlayers();
          },
          child: const Text("Update"),
        ),
      ],
    ),
  );
}

  Future<void> deletePlayer(int id) async {
    await DatabaseHelper.instance.deletePlayer(id);
    loadPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Players"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addPlayer,
        child: const Icon(Icons.add),
      ),
      body: players.isEmpty
          ? const Center(
              child: Text("No Players Added"),
            )
          : ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(player.name),
                    subtitle: Text("Rating: ${player.rating}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            editPlayer(player);
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
                                title: const Text("Delete Player"),
                                content: const Text(
                                  "Are you sure you want to delete this player?",
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
                              await deletePlayer(player.id!);
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