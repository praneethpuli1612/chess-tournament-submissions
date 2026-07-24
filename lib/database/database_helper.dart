import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/player.dart';
import '../models/tournament.dart';

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
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE tournaments(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              location TEXT NOT NULL
            )
          ''');
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
  }

  // ---------------- PLAYER CRUD ----------------

  Future<Player> createPlayer(Player player) async {
    final db = await database;

    final id = await db.insert(
      'players',
      player.toMap(),
    );

    return Player(
      id: id,
      name: player.name,
      rating: player.rating,
    );
  }

  Future<List<Player>> getPlayers() async {
    final db = await database;

    final result = await db.query('players');

    return result.map((e) => Player.fromMap(e)).toList();
  }

  Future<int> updatePlayer(Player player) async {
    final db = await database;

    return db.update(
      'players',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  Future<int> deletePlayer(int id) async {
    final db = await database;

    return db.delete(
      'players',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------- TOURNAMENT CRUD ----------------

  Future<Tournament> createTournament(Tournament tournament) async {
    final db = await database;

    final id = await db.insert(
      'tournaments',
      tournament.toMap(),
    );

    return Tournament(
      id: id,
      name: tournament.name,
      location: tournament.location,
    );
  }

  Future<List<Tournament>> getTournaments() async {
    final db = await database;

    final result = await db.query('tournaments');

    return result.map((e) => Tournament.fromMap(e)).toList();
  }

  Future<int> updateTournament(Tournament tournament) async {
    final db = await database;

    return db.update(
      'tournaments',
      tournament.toMap(),
      where: 'id = ?',
      whereArgs: [tournament.id],
    );
  }

  Future<int> deleteTournament(int id) async {
    final db = await database;

    return db.delete(
      'tournaments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}