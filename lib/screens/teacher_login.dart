import 'dart:convert';  // For JSON decoding
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Login',
      home: TeacherLogin(),
    );
  }
}

class TeacherLogin extends StatefulWidget {
  @override
  _TeacherLoginState createState() => _TeacherLoginState();
}

class _TeacherLoginState extends State<TeacherLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String _loginMessage = '';  // To store the login status message

  Future<void> login(String email, String password) async {
    setState(() {
      _loginMessage = 'Logging in...';
    });

    try {
      final response = await http.post(
        Uri.parse('https://7fa9-2401-4900-57cc-3d4-81cd-9d06-7fc6-9ba.ngrok-free.app/attendance_api/teacher_login.php'), // Replace with your actual PHP URL
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody['success'] == true) {
          setState(() {
            _loginMessage = responseBody['message']; // Login successful
          });
          // You can navigate to another screen here if needed.
        } else {
          setState(() {
            _loginMessage = responseBody['message']; // Display error message
          });
        }
      } else {
        setState(() {
          _loginMessage = 'Error: ${response.statusCode}'; // HTTP error code
        });
      }
    } catch (e) {
      setState(() {
        _loginMessage = 'Error: $e'; // Handle errors like network issues
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String email = emailController.text.trim();
                String password = passwordController.text.trim();
                if (email.isNotEmpty && password.isNotEmpty) {
                  login(email, password);
                } else {
                  setState(() {
                    _loginMessage = 'Please fill in both fields';
                  });
                }
              },
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            Text(
              _loginMessage,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
