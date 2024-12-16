import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // Add this in pubspec.yaml
import 'package:path/path.dart'; // For database path
import 'screens/student_register.dart';
import 'screens/student_login.dart';
import 'screens/teacher_register.dart'; // Import Teacher Registration
import 'screens/teacher_login.dart'; // Import Teacher Login
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
              text: 'Teacher Register', // Add Teacher Register Button
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TeacherRegister()),
                );
              },
            ),
            CustomButton(
              text: 'Teacher Login', // Add Teacher Login Button
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TeacherLogin()),
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
      String path = join(dbPath, 'attendance.db'); // Changed database name
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          // Create students table
          await db.execute('''
            CREATE TABLE students (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL,
              prn TEXT NOT NULL,
              email TEXT NOT NULL,
              uuid TEXT NOT NULL
            )
          ''');
          // Create teachers table
          await db.execute('''
            CREATE TABLE teachers (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              teacher_id TEXT NOT NULL,
              email TEXT NOT NULL,
              username TEXT NOT NULL,
              password TEXT NOT NULL
            )
          ''');
        },
      );
      debugPrint("Database initialized at $path");
    } catch (e) {
      debugPrint("Error initializing database: $e");
    }
  }

  // Save Student
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

  // Save Teacher
  static Future<void> saveTeacher({
    required String teacherId,
    required String email,
    required String username,
    required String password,
  }) async {
    if (_database == null) await initDatabase();
    try {
      await _database?.insert(
        'teachers',
        {
          'teacher_id': teacherId,
          'email': email,
          'username': username,
          'password': password,
        },
      );
      debugPrint("Teacher $username inserted successfully.");
    } catch (e) {
      debugPrint("Error saving teacher: $e");
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

  // Fetch all teachers
  static Future<List<Map<String, dynamic>>> fetchAllTeachers() async {
    if (_database == null) await initDatabase();
    try {
      return await _database!.query('teachers');
    } catch (e) {
      debugPrint("Error fetching teachers: $e");
      return [];
    }
  }

  // Validate Teacher Login
  static Future<bool> validateTeacherLogin({
    required String email,
    required String password,
  }) async {
    if (_database == null) await initDatabase();
    try {
      final result = await _database?.query(
        'teachers',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      return result != null && result.isNotEmpty;
    } catch (e) {
      debugPrint("Error validating teacher login: $e");
      return false;
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
