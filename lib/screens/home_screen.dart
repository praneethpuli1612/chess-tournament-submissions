import 'package:flutter/material.dart';
import 'players_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chess Tournament"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const SizedBox(height: 20),

            ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlayersScreen(),
      ),
    );
  },
  icon: const Icon(Icons.people),
  label: const Text("Players"),
),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.emoji_events),
              label: const Text("Tournaments"),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.leaderboard),
              label: const Text("Rankings"),
            ),
          ],
        ),
      ),
    );
  }
}