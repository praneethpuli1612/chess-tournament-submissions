import 'package:flutter/material.dart';
import 'dart:math';
import 'matches_screen.dart';
import '../models/match.dart';
import '../database/database_helper.dart';
import '../models/player.dart';
import '../models/tournament.dart';
import '../models/tournament_player.dart';

class TournamentDetailsScreen extends StatefulWidget {
  final Tournament tournament;

  const TournamentDetailsScreen({
    super.key,
    required this.tournament,
  });

  @override
  State<TournamentDetailsScreen> createState() =>
      _TournamentDetailsScreenState();
}

class _TournamentDetailsScreenState
    extends State<TournamentDetailsScreen> {

  List<Player> allPlayers = [];
  List<Player> tournamentPlayers = [];

    @override
  void initState() {
    super.initState();
    loadPlayers();
  }

  Future<void> addPlayersDialog() async {
    final selectedPlayers =
        tournamentPlayers.map((e) => e.id).toSet();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(24),
              ),
              title: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Color(0xff1E3A8A),
                    child: Icon(
                      Icons.people,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Manage Players",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 420,
                child: allPlayers.isEmpty
                    ? const Center(
                        child: Text(
                          "No players available.",
                        ),
                      )
                    : ListView.builder(
                        itemCount:
                            allPlayers.length,
                        itemBuilder:
                            (context, index) {
                          final player =
                              allPlayers[index];

                          return Card(
                            elevation: 3,
                            margin:
                                const EdgeInsets
                                    .only(
                              bottom: 10,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          18),
                            ),
                            child:
                                CheckboxListTile(
                              value:
                                  selectedPlayers
                                      .contains(
                                player.id,
                              ),
                              activeColor:
                                  const Color(
                                      0xff1E3A8A),
                              secondary:
                                  CircleAvatar(
                                backgroundColor:
                                    const Color(
                                            0xff2563EB)
                                        .withOpacity(
                                            .12),
                                child: Text(
                                  player.name[0]
                                      .toUpperCase(),
                                  style:
                                      const TextStyle(
                                    color: Color(
                                        0xff1E3A8A),
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                player.name,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                              subtitle: Text(
                                "Rating ${player.rating}",
                              ),
                              onChanged: (value) {
                                setDialogState(() {
                                  if (value ==
                                      true) {
                                    selectedPlayers
                                        .add(
                                      player.id,
                                    );
                                  } else {
                                    selectedPlayers
                                        .remove(
                                      player.id,
                                    );
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context),
                  child:
                      const Text("Cancel"),
                ),
                ElevatedButton.icon(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                            0xff1E3A8A),
                    foregroundColor:
                        Colors.white,
                  ),
                  icon:
                      const Icon(Icons.save),
                  label:
                      const Text("Save"),
                  onPressed: () async {
                    for (final player
                        in tournamentPlayers) {
                      await DatabaseHelper
                          .instance
                          .removePlayerFromTournament(
                        widget.tournament.id!,
                        player.id!,
                      );
                    }

                    for (final id
                        in selectedPlayers) {
                      await DatabaseHelper
                          .instance
                          .addPlayerToTournament(
                        TournamentPlayer(
                          tournamentId:
                              widget
                                  .tournament
                                  .id!,
                          playerId: id!,
                        ),
                      );
                    }

                    Navigator.pop(context);

                    loadPlayers();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

Future<void> generatePairings() async {
  if (tournamentPlayers.length < 2) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("At least 2 players are required."),
      ),
    );
    return;
  }

  await DatabaseHelper.instance
      .deleteMatches(widget.tournament.id!);

  final shuffled = List<Player>.from(tournamentPlayers);

  shuffled.shuffle(Random());

  for (int i = 0; i < shuffled.length - 1; i += 2) {
    await DatabaseHelper.instance.createMatch(
      ChessMatch(
        tournamentId: widget.tournament.id!,
        player1Id: shuffled[i].id!,
        player2Id: shuffled[i + 1].id!,
      ),
    );
  }

  if (shuffled.length.isOdd) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${shuffled.last.name} receives a BYE.",
        ),
      ),
    );
  }

  if (!mounted) return;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MatchesScreen(
        tournamentId: widget.tournament.id!,
      ),
    ),
  );

  loadPlayers();
}

Future<void> loadPlayers() async {
  allPlayers =
      await DatabaseHelper.instance.getPlayers();

  final links =
      await DatabaseHelper.instance
          .getTournamentPlayers(
    widget.tournament.id!,
  );

  tournamentPlayers = [];

  for (final link in links) {
    final player = allPlayers.firstWhere(
      (p) => p.id == link.playerId,
    );

    tournamentPlayers.add(player);
  }

  if (mounted) {
    setState(() {});
  }
}

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tournament.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff0F172A),
                    Color(0xff1E3A8A),
                    Color(0xff2563EB),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 40,
                        ),
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.12),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${tournamentPlayers.length} Players",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Text(
                    widget.tournament.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [

                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 18,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        widget.tournament.location,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Players",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            tournamentPlayers.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(45),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.06),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 75,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 15),
                        Text(
                          "No Players Added",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: tournamentPlayers.length,
                    itemBuilder: (_, index) {

                      final player =
                          tournamentPlayers[index];

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 16,
                        ),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(22),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.all(16),

                          leading: Container(
                            width: 58,
                            height: 58,
                            decoration:
                                const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xff2563EB),
                                  Color(0xff1E3A8A),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                player.name[0]
                                    .toUpperCase(),
                                style:
                                    const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          title: Text(
                            player.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          subtitle: Padding(
                            padding:
                                const EdgeInsets.only(
                                    top: 8),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.amber.shade100,
                                borderRadius:
                                    BorderRadius.circular(
                                        20),
                              ),
                              child: Text(
                                "⭐ Rating ${player.rating}",
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          trailing: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                      );
                    },
                  ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize:
                    const Size(double.infinity, 60),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                ),
              ),
              onPressed: addPlayersDialog,
              icon: const Icon(Icons.person_add),
              label: const Text(
                "Manage Players",
                style: TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize:
                    const Size(double.infinity, 60),
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                ),
              ),
              onPressed: generatePairings,
              icon: const Icon(Icons.casino),
              label: const Text(
                "Generate Pairings",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}