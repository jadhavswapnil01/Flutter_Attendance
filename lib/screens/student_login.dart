import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/database_helper.dart';
import './student_dashboard.dart';
import 'constants.dart';
import 'package:untitled4/screens/background_scaffold.dart';
import 'student_register.dart';

class StudentLogin extends StatefulWidget {
  const StudentLogin({super.key});

  @override
  State<StudentLogin> createState() => _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String message = '';
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Password visibility toggle

  Future<String?> getStudentUuid(String username) async {
    String? uuid = await DatabaseHelper.fetchUuidByUsername(username);

    if (uuid != null) {
      debugPrint("UUID for $username: $uuid");
    } else {
      debugPrint("UUID not found for $username.");
    }
    return uuid;
  }

  Future<void> loginUser() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final uuid = await getStudentUuid(username);

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        message = 'Username and password are required.';
      });
      return;
    }

    if (uuid == null) {
      setState(() {
        message = 'Wrong Username OR you are trying to login another student account.';
      });
      return;
    }

    const url = '${APIConstants.baseUrl}/attendance_api/login.php';

    setState(() {
      _isLoading = true;
    });

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

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          setState(() {
            message = 'Login Successful!';
          });
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
        }
      } else {
        setState(() {
          message = 'Server error. Try again later.';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Unable to connect to the server.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Student Login',
          style: TextStyle(
            color: Color(0xFF673AB7),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF673AB7)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF673AB7),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login to your account',
                style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 2, 2, 2)),
              ),
              const SizedBox(height: 30),
              _buildInputField(
                controller: _usernameController,
                labelText: 'Username',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                controller: _passwordController,
                labelText: 'Password',
                icon: Icons.lock_outline,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : loginUser,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: const Color(0xFF673AB7),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Logging in...', style: TextStyle(fontSize: 18)),
                          ],
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentRegister(),
                    ),
                  );
                },
                child: const Text(
                  'Don’t have an account? Register here.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF673AB7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      obscureText: obscureText,
    );
  }
}
