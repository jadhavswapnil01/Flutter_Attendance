import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // Add this in pubspec.yaml
import 'package:path/path.dart'; // For database path
import 'screens/student_register.dart';
import 'screens/student_login.dart';
import 'widgets/custom_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: 'Student Register',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StudentRegister()),
                );
              },
            ),
            CustomButton(
              text: 'Student Login',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StudentLogin()),
                );
              },
            ),
            CustomButton(
              text: 'View All Students',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StudentsList()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Database Helper
class DatabaseHelper {
  static Database? _database;

  // Initialize database
  static Future<void> initDatabase() async {
    if (_database != null) return;
    try {
      String dbPath = await getDatabasesPath();
      String path = join(dbPath, 'students.db');
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

  // Insert student into the database
  static Future<void> saveStudent({
    required String username,
    required String prn,
    required String email,
    required String uuid,
  }) async {
    if (_database == null) await initDatabase();
    try {
      await _database?.insert(
        'students',
        {
          'username': username,
          'prn': prn,
          'email': email,
          'uuid': uuid,
        },
      );
      debugPrint("Student $username inserted successfully.");
    } catch (e) {
      debugPrint("Error saving student: $e");
    }
  }

  // Fetch all students
  static Future<List<Map<String, dynamic>>> fetchAllStudents() async {
    if (_database == null) await initDatabase();
    try {
      return await _database!.query('students');
    } catch (e) {
      debugPrint("Error fetching students: $e");
      return [];
    }
  }
}

// Students List Screen
class StudentsList extends StatelessWidget {
  const StudentsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stored Students')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.fetchAllStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No students found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final student = snapshot.data![index];
              return ListTile(
                title: Text(student['username']),
                subtitle: Text('PRN: ${student['prn']}, Email: ${student['email']}'),
              );
            },
          );
        },
      ),
    );
  }
}
