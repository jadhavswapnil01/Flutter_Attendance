import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

class DatabaseHelper {
  static Database? _database;

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
      debugPrint("Database initialized at $path");
    } catch (e) {
      debugPrint("Error initializing database: $e");
    }
  }

  // Insert a new student into the database
  // Modify saveStudent method in database_helper.dart
static Future<void> saveStudent(Map<String, String> studentData) async {
  if (_database == null) await initDatabase();

  try {
    await _database?.insert(
      'students',
      studentData, // Directly use the passed map
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint("Student ${studentData['username']} inserted successfully.");
  } catch (e) {
    debugPrint("Error saving student: $e");
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
}
