// screens/student_login.dart
import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart'; // For local database
// import 'package:path/path.dart'; // For handling database paths
import 'dart:convert'; // For JSON encoding
import 'package:http/http.dart' as http; // For API requests
import '../helpers/database_helper.dart';
import './student_dashboard.dart';

class StudentLogin extends StatefulWidget {
  const StudentLogin({super.key});

  @override
  State<StudentLogin> createState() => _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String message = '';

  // Local database function to get the UUID
  Future<String?> getStudentUuid(String username) async {
  String? uuid = await DatabaseHelper.fetchUuidByUsername(username);

  if (uuid != null) {
    debugPrint("UUID for $username: $uuid");
  } else {
    debugPrint("UUID not found for $username.");
  }
  return uuid;
}


  // Function to handle login
  Future<void> loginUser() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final uuid = await getStudentUuid(username);

    if (username.isEmpty || password.isEmpty || uuid == null) {
      setState(() {
        message = 'All fields are required.';
      });
      return;
    }

    // Backend API URL
    const url = 'https://7fa9-2401-4900-57cc-3d4-81cd-9d06-7fc6-9ba.ngrok-free.app/attendance_api/login.php'; // Replace with your XAMPP IP

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'username': username,
          'password': password,
          'uuid': uuid,
        },
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        setState(() {
          message = 'Login Successful!';
        });
        // Navigate to the next screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentDashboard(uuid: uuid),
          ),
        );
      } else {
        setState(() {
          message = responseData['message'];
        });
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudentDashboard(uuid: uuid),
        ),
      );
      }
    } catch (e) {
      setState(() {
        message = 'Login failed. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Login'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loginUser,
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
