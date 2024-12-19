import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'teacher_login.dart';

class TeacherRegister extends StatefulWidget {
  const TeacherRegister({Key? key}) : super(key: key);

  @override
  State<TeacherRegister> createState() => _TeacherRegisterState();
}

class _TeacherRegisterState extends State<TeacherRegister> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _teacherIdController = TextEditingController();
  bool _isLoading = false;

  Future<void> _registerTeacher() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final uri = Uri.parse(
          '${APIConstants.baseUrl}/attendance_api/teacher_register.php');
      var request = http.MultipartRequest('POST', uri)
        ..fields['username'] = _usernameController.text
        ..fields['password'] = _passwordController.text
        ..fields['teacher_id'] = _teacherIdController.text
        ..fields['email'] = _emailController.text;

      try {
        var response = await request.send();
        var responseBody = await http.Response.fromStream(response);
        var json = jsonDecode(responseBody.body);

        if (response.statusCode == 200 && json['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(json['message'])),
          );
          _clearForm();
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TeacherLogin(),
          ),
          );

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(json['message'] ?? 'Failed to register teacher.')),
          );
        }
      } catch (e) {
        debugPrint('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _teacherIdController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF673AB7); // Green theme color
    final secondaryColor = Color.fromARGB(255, 255, 255, 255); // Darker green for accents

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Teacher Registration',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Register a New Teacher',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                _buildInputField(
                  controller: _teacherIdController,
                  labelText: 'Teacher ID',
                  hintText: 'Enter Teacher ID',
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  controller: _usernameController,
                  labelText: 'Username',
                  hintText: 'Enter Username',
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Enter Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter an email';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                        .hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter Password',
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerTeacher,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      backgroundColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Register Teacher',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF673AB7), width: 2.0),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator ?? (value) => value!.isEmpty ? 'This field is required' : null,
    );
  }
}
