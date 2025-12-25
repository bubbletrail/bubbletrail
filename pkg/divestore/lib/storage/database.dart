import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SsrfDatabase {
  static Database? _database;
  static const int _version = 3;
  static Future<Database> Function()? _testDatabaseFactory;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    if (_testDatabaseFactory != null) {
      _database = await _testDatabaseFactory!();
    } else {
      _database = await _initDatabase();
    }
    return _database!;
  }

  /// Set up a test database factory. Call this before any database operations in tests.
  static void setTestDatabaseFactory(Future<Database> Function() factory) {
    _testDatabaseFactory = factory;
  }

  /// Create the database schema on the given database instance.
  static Future<void> createSchema(Database db) => _onCreate(db, _version);

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'bubbletrail.db');
    return openDatabase(path, version: _version, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE divesites ADD COLUMN country TEXT');
      await db.execute('ALTER TABLE divesites ADD COLUMN location TEXT');
      await db.execute('ALTER TABLE divesites ADD COLUMN body_of_water TEXT');
      await db.execute('ALTER TABLE divesites ADD COLUMN difficulty TEXT');
    }
    if (oldVersion < 3) {
      // Drop old dive computer log tables
      await db.execute('DROP TABLE IF EXISTS samples');
      await db.execute('DROP TABLE IF EXISTS events');
      await db.execute('DROP TABLE IF EXISTS dive_computer_logs');

      // Create new computer_dives table with JSON storage
      await db.execute('''
        CREATE TABLE computer_dives (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          dive_id TEXT NOT NULL,
          idx INTEGER NOT NULL,
          data TEXT NOT NULL,
          FOREIGN KEY (dive_id) REFERENCES dives (id) ON DELETE CASCADE
        )
      ''');
      await db.execute('CREATE INDEX idx_computer_dives_dive_id ON computer_dives (dive_id)');
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE divesites (
        uuid TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        lat REAL,
        lon REAL,
        country TEXT,
        location TEXT,
        body_of_water TEXT,
        difficulty TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE dives (
        id TEXT PRIMARY KEY,
        number INTEGER NOT NULL,
        rating INTEGER,
        start INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        max_depth REAL,
        mean_depth REAL,
        sac REAL,
        otu INTEGER,
        cns INTEGER,
        divesiteid TEXT,
        divemaster TEXT,
        notes TEXT,
        FOREIGN KEY (divesiteid) REFERENCES divesites (uuid)
      )
    ''');

    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE buddies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE dive_tags (
        dive_id TEXT NOT NULL,
        tag_id INTEGER NOT NULL,
        PRIMARY KEY (dive_id, tag_id),
        FOREIGN KEY (dive_id) REFERENCES dives (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE dive_buddies (
        dive_id TEXT NOT NULL,
        buddy_id INTEGER NOT NULL,
        PRIMARY KEY (dive_id, buddy_id),
        FOREIGN KEY (dive_id) REFERENCES dives (id) ON DELETE CASCADE,
        FOREIGN KEY (buddy_id) REFERENCES buddies (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE cylinders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        size REAL,
        workpressure REAL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE dive_cylinders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dive_id TEXT NOT NULL,
        cylinder_id INTEGER NOT NULL,
        idx INTEGER NOT NULL,
        start_pressure REAL,
        end_pressure REAL,
        o2 REAL,
        he REAL,
        FOREIGN KEY (dive_id) REFERENCES dives (id) ON DELETE CASCADE,
        FOREIGN KEY (cylinder_id) REFERENCES cylinders (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE weightsystems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dive_id TEXT NOT NULL,
        idx INTEGER NOT NULL,
        weight REAL,
        description TEXT,
        FOREIGN KEY (dive_id) REFERENCES dives (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE divecomputers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        model TEXT NOT NULL,
        serial TEXT,
        deviceid TEXT,
        diveid TEXT,
        fingerprint_data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE computer_dives (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dive_id TEXT NOT NULL,
        idx INTEGER NOT NULL,
        data TEXT NOT NULL,
        FOREIGN KEY (dive_id) REFERENCES dives (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_dives_divesiteid ON dives (divesiteid)');
    await db.execute('CREATE INDEX idx_dives_start ON dives (start)');
    await db.execute('CREATE INDEX idx_dive_tags_dive_id ON dive_tags (dive_id)');
    await db.execute('CREATE INDEX idx_dive_buddies_dive_id ON dive_buddies (dive_id)');
    await db.execute('CREATE INDEX idx_dive_cylinders_dive_id ON dive_cylinders (dive_id)');
    await db.execute('CREATE INDEX idx_weightsystems_dive_id ON weightsystems (dive_id)');
    await db.execute('CREATE INDEX idx_computer_dives_dive_id ON computer_dives (dive_id)');
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
