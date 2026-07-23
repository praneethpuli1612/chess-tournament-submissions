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

                return ListTile(
                  title: Text(player.name),
                  subtitle: Text("Rating : ${player.rating}"),
                );

              },
            ),
    );
  }
}