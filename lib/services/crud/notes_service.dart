import 'package:flutter/cupertino.dart';
import 'package:privatenotes/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;

class NotesService {
  Database? _db;
  // CRUD operations for notes and users
  // Update Note
  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updatesCount = db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return await getNote(id: note.id);
    }
  }

  // Get All Notes
  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  // Get Single Note
  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: "id = ?",
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      return DatabaseNote.fromRow(notes.first);
    }
  }

  // Delete all notes
  Future<int> deleteAll() async {
    final db = _getDatabaseOrThrow();
    final deleteAllNotes = await db.delete(noteTable);
    return deleteAllNotes;
  }

  // Delete a note
  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: "$id = ?",
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  // Create a note
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    // make sure owner exists in the database with correct id
    final dbUser = await getUser(email: owner.email);

    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }
    const text = '';
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
    return note;
  }

  // Create a user
  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final normalizedEmail = email.toLowerCase();
    final results = await db.query(
      userTable,
      limit: 1,
      where: '$emailColumn = ?',
      whereArgs: [normalizedEmail],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }
    final userId = await db.insert(userTable, {emailColumn: normalizedEmail});
    return DatabaseUser(id: userId, email: normalizedEmail);
  }

  // Create a user
  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final normalizedEmail = email.toLowerCase();
    final results = await db.query(
      userTable,
      limit: 1,
      where: '$emailColumn = ?',
      whereArgs: [normalizedEmail],
    );
    if (results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  // Delete a user
  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  // Get database or throw
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  // Close database
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  // Open database
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // create user table
      await db.execute(createUserTable);

      // create note table
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      email = map[emailColumn] as String;
  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });
  DatabaseNote.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      userId = map[userIdColumn] as int,
      text = map[textColumn] as String,
      isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1
          ? true
          : false;
  @override
  String toString() =>
      "Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text";

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// user
const idColumn = 'id';
const emailColumn = 'email';
// notes
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
// database
const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';

// create user table
const createUserTable =
    '''
      CREATE TABLE IF NOT EXISTS $userTable (
        $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
        $emailColumn TEXT NOT NULL UNIQUE
      );
      ''';
// create note table
const createNoteTable =
    '''
      CREATE TABLE IF NOT EXISTS $noteTable (
        $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
        $userIdColumn INTEGER NOT NULL,
        $textColumn TEXT,
        $isSyncedWithCloudColumn INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY ($userIdColumn) REFERENCES $userTable($idColumn)
      );
      ''';
