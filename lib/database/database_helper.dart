import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/match.dart';
import '../models/player.dart';
import '../models/tournament.dart';
import '../models/tournament_player.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chess_tournament.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          await db.execute('DROP TABLE IF EXISTS matches');
          await db.execute('DROP TABLE IF EXISTS tournament_players');
          await db.execute('DROP TABLE IF EXISTS tournaments');
          await db.execute('DROP TABLE IF EXISTS players');
          await _createDB(db, newVersion);
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE players(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        rating INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tournaments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tournament_players(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tournamentId INTEGER NOT NULL,
        playerId INTEGER NOT NULL,
        UNIQUE(tournamentId, playerId),
        FOREIGN KEY (tournamentId) REFERENCES tournaments (id) ON DELETE CASCADE,
        FOREIGN KEY (playerId) REFERENCES players (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE matches(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tournamentId INTEGER NOT NULL,
        player1Id INTEGER NOT NULL,
        player2Id INTEGER NOT NULL,
        winnerId INTEGER,
        FOREIGN KEY (tournamentId) REFERENCES tournaments (id) ON DELETE CASCADE,
        FOREIGN KEY (player1Id) REFERENCES players (id) ON DELETE CASCADE,
        FOREIGN KEY (player2Id) REFERENCES players (id) ON DELETE CASCADE,
        FOREIGN KEY (winnerId) REFERENCES players (id) ON DELETE SET NULL
      )
    ''');
  }

  // ---------------- PLAYER CRUD ----------------

  Future<Player> createPlayer(Player player) async {
    final db = await database;
    final id = await db.insert('players', player.toMap());
    return player.copyWith(id: id);
  }

  Future<List<Player>> getPlayers() async {
    final db = await database;
    final result = await db.query('players', orderBy: 'rating DESC');
    return result.map((e) => Player.fromMap(e)).toList();
  }

  Future<int> updatePlayer(Player player) async {
    final db = await database;
    return db.update('players', player.toMap(), where: 'id = ?', whereArgs: [player.id]);
  }

  Future<int> deletePlayer(int id) async {
    final db = await database;
    return db.delete('players', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- TOURNAMENT CRUD ----------------

  Future<Tournament> createTournament(Tournament tournament) async {
    final db = await database;
    final id = await db.insert('tournaments', tournament.toMap());
    return tournament.copyWith(id: id);
  }

  Future<List<Tournament>> getTournaments() async {
    final db = await database;
    final result = await db.query('tournaments', orderBy: 'id DESC');
    return result.map((e) => Tournament.fromMap(e)).toList();
  }

  Future<int> updateTournament(Tournament tournament) async {
    final db = await database;
    return db.update('tournaments', tournament.toMap(), where: 'id = ?', whereArgs: [tournament.id]);
  }

  Future<int> deleteTournament(int id) async {
    final db = await database;
    return db.delete('tournaments', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- TOURNAMENT PLAYERS ----------------

  Future<void> addPlayerToTournament(TournamentPlayer tournamentPlayer) async {
    final db = await database;
    await db.insert('tournament_players', tournamentPlayer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TournamentPlayer>> getTournamentPlayers(int tournamentId) async {
    final db = await database;
    final result = await db.query('tournament_players', where: 'tournamentId = ?', whereArgs: [tournamentId]);
    return result.map((e) => TournamentPlayer.fromMap(e)).toList();
  }

  Future<void> removePlayerFromTournament(int tournamentId, int playerId) async {
    final db = await database;
    await db.delete('tournament_players', where: 'tournamentId = ? AND playerId = ?', whereArgs: [tournamentId, playerId]);
  }

  // ---------------- MATCHES ----------------

  Future<void> createMatch(ChessMatch match) async {
    final db = await database;
    await db.insert('matches', match.toMap());
  }

  Future<List<ChessMatch>> getMatches(int tournamentId) async {
    final db = await database;
    final result = await db.query('matches', where: 'tournamentId = ?', whereArgs: [tournamentId]);
    return result.map((e) => ChessMatch.fromMap(e)).toList();
  }

  Future<void> updateWinner(int matchId, int winnerId) async {
    final db = await database;
    await db.update('matches', {'winnerId': winnerId}, where: 'id = ?', whereArgs: [matchId]);
  }

  Future<void> deleteMatches(int tournamentId) async {
    final db = await database;
    await db.delete('matches', where: 'tournamentId = ?', whereArgs: [tournamentId]);
  }

  // ---------------- RANKINGS & STATS ----------------

  Future<List<Map<String, dynamic>>> getRankings({int? tournamentId}) async {
    final db = await database;
    if (tournamentId != null) {
      return await db.rawQuery('''
        SELECT players.id, players.name, COUNT(matches.winnerId) AS wins
        FROM tournament_players
        JOIN players ON tournament_players.playerId = players.id
        LEFT JOIN matches ON players.id = matches.winnerId AND matches.tournamentId = ?
        WHERE tournament_players.tournamentId = ?
        GROUP BY players.id, players.name
        ORDER BY wins DESC, players.rating DESC
      ''', [tournamentId, tournamentId]);
    }

    return await db.rawQuery('''
      SELECT players.id, players.name, COUNT(matches.winnerId) AS wins
      FROM players
      LEFT JOIN matches ON players.id = matches.winnerId
      GROUP BY players.id, players.name
      ORDER BY wins DESC, players.rating DESC
    ''');
  }

  Future<int> getPlayerCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM players');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTournamentCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM tournaments');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getMatchCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM matches');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getWinnerCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM matches WHERE winnerId IS NOT NULL');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}