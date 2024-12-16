import 'dart:convert';
// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

    final uri = Uri.parse('https://7fa9-2401-4900-57cc-3d4-81cd-9d06-7fc6-9ba.ngrok-free.app/attendance_api/teacher_register.php');
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(json['message'] ?? 'Failed to register teacher.')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Registration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Register a New Teacher',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _teacherIdController,
                  decoration: const InputDecoration(
                    labelText: 'Teacher ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter a teacher ID' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter a username' : null,
                ),
                const SizedBox(height: 10),
                
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                   border: OutlineInputBorder(),
                 ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter an email';
                     }
                    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter a password' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerTeacher,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Register Teacher'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}