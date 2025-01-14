// import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  DatabaseHelper._privateConstructor();
  static Database? _database;
  final secureStorage = FlutterSecureStorage();
  // Encryption key for UUID storage
  static final _encryptionKey = encrypt.Key.fromUtf8('my32charpasswordmy32charpassword'); // 32 chars
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));
  static final _iv = encrypt.IV.fromLength(16); // 16 bytes IV
  static const _uuidFileName = '.secure_uuid';

  // Initialize the database
  static Future<void> initDatabase() async {
    if (_database != null) return;

    try {
      // Get the database path
      String dbPath = await getDatabasesPath();
      String path = join(dbPath, 'students.db');

      // Open the database and create the students table
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE students (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL,
              prn TEXT NOT NULL,
              email TEXT NOT NULL,
              uuid TEXT NOT NULL
            )
          ''');
        },
      );

      // Ensure the secure folder for UUID exists
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_uuidFileName');
      if (!file.existsSync()) {
        file.createSync();
      }

      debugPrint("Database initialized at $path");
    } catch (e) {
      debugPrint("Error initializing database: $e");
    }
  }

  // Save UUID securely
 Future<void> saveUuidToSecureStorage(String uuid) async {
  await secureStorage.write(key: 'secure_uuid', value: uuid);
}

// Fetch UUID securely
Future<String?> fetchUuidFromSecureStorage() async {
  return await secureStorage.read(key: 'secure_uuid');
}

  // Save UUID securely in a file
   Future<void> saveUuidToFile(String uuid) async {
    try {
      saveUuidToSecureStorage(uuid);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_uuidFileName');

      // Encrypt the UUID
      final encryptedUuid = _encrypter.encrypt(uuid, iv: _iv).base64;

      // Write the encrypted UUID to the file
      await file.writeAsString(encryptedUuid, flush: true);
      debugPrint("UUID saved securely in ${file.path}");
    } catch (e) {
      debugPrint("Error saving UUID: $e");
    }
  }

  // Fetch UUID from the secure file
   Future<String?> fetchUuidFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_uuidFileName');

      if (await file.exists()) {
        final encryptedUuid = await file.readAsString();
        return _encrypter.decrypt64(encryptedUuid, iv: _iv);
      }else {
       return fetchUuidFromSecureStorage();
      }
      // return null;
    } catch (e) {
      debugPrint("Error fetching UUID from file: $e");
      return null;
    }
  }

  // Insert a new student into the database
   Future<void> saveStudent(Map<String, String> studentData) async {
    if (_database == null) await initDatabase();

    try {
      await _database?.insert(
        'students',
        studentData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Save UUID securely in the file
      if (studentData['uuid'] != null) {
        await saveUuidToFile(studentData['uuid']!);
      }

      debugPrint("Student ${studentData['email']} inserted successfully.");
    } catch (e) {
      debugPrint("Error saving student: $e");
    }
  }

  // Fetch the UUID of a specific student by email
   Future<String?> fetchUuidByEmail(String email) async {
    if (_database == null) await initDatabase();

    try {
      // Check in the database first
      final List<Map<String, dynamic>> result = await _database!.query(
        'students',
        columns: ['uuid'],
        where: 'email = ?',
        whereArgs: [email],
      );

      if (result.isNotEmpty) {
        return result.first['uuid'] as String;
      }

      // If not found, check in the secure file
      final uuidFromFile = await fetchUuidFromFile();
      if (uuidFromFile != null) {
        // Copy the UUID to the database for the given email
        await _database!.update(
          'students',
          {'uuid': uuidFromFile},
          where: 'email = ?',
          whereArgs: [email],
        );
        return uuidFromFile;
      }

      debugPrint("No UUID found for Email $email.");
      return null;
    } catch (e) {
      debugPrint("Error fetching UUID: $e");
      return null;
    }
  }

  // Fetch all students from the database
  static Future<List<Map<String, dynamic>>> fetchAllStudents() async {
    if (_database == null) await initDatabase();

    try {
      return await _database!.query('students');
    } catch (e) {
      debugPrint("Error fetching students: $e");
      return [];
    }
  }

  // Other methods remain unchanged...



  // Fetch a student by ID
  static Future<Map<String, dynamic>?> fetchStudentById(int id) async {
    if (_database == null) await initDatabase();

    try {
      final List<Map<String, dynamic>> result =
          await _database!.query('students', where: 'id = ?', whereArgs: [id]);
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      debugPrint("Error fetching student by ID: $e");
      return null;
    }
  }

  // Update student details
  static Future<void> updateStudent({
    required int id,
    required String username,
    required String prn,
    required String email,
    required String uuid,
  }) async {
    if (_database == null) await initDatabase();

    try {
      await _database!.update(
        'students',
        {
          'username': username,
          'prn': prn,
          'email': email,
          'uuid': uuid,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint("Student with ID $id updated successfully.");
    } catch (e) {
      debugPrint("Error updating student: $e");
    }
  }

  // Delete a student from the database
  static Future<void> deleteStudent(int id) async {
    if (_database == null) await initDatabase();

    try {
      await _database!.delete(
        'students',
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint("Student with ID $id deleted successfully.");
    } catch (e) {
      debugPrint("Error deleting student: $e");
    }
  }

  // Check if a UUID exists in the database
 Future<bool> doesUuidExist(String uuid, String email) async {
  if (_database == null) await initDatabase();

  try {
    // Step 1: Check if the UUID exists in the database
    final List<Map<String, dynamic>> result = await _database!.query(
      'students',
      columns: ['id'], // Fetching only the ID to reduce overhead
      where: 'uuid = ?',
      whereArgs: [uuid],
    );

    if (result.isNotEmpty) {
      debugPrint("UUID $uuid exists in the database.");
      return true;
    }

    // Step 2: Check if the UUID exists in the secure folder
    final uuidFromFile = await fetchUuidFromFile();
    if (uuidFromFile == uuid) {
      debugPrint("UUID $uuid found in the secure folder.");

      // Step 3: Copy the UUID from the secure folder into the database for the provided email
      await _database!.update(
        'students',
        {'uuid': uuid},
        where: 'email = ?',
        whereArgs: [email],
      );

      debugPrint("UUID $uuid copied from the secure folder to the database for email $email.");
      return true;
    }

    debugPrint("UUID $uuid does not exist in the database or secure folder.");
    return false;
  } catch (e) {
    debugPrint("Error checking UUID: $e");
    return false;
  }
}


}
