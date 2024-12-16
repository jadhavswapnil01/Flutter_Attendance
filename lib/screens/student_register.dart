import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../helpers/database_helper.dart'; // Ensure this path matches your project structure

class StudentRegister extends StatefulWidget {
  const StudentRegister({Key? key}) : super(key: key);

  @override
  State<StudentRegister> createState() => _StudentRegisterState();
}

class _StudentRegisterState extends State<StudentRegister> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _prnController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final Uuid uuid = Uuid();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _registerStudent() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });

      final String studentUuid = uuid.v4();
      final uri = Uri.parse('https://a64b-2402-8100-3129-1b4a-302c-5e30-9bd5-f3a5.ngrok-free.app/attendance_api/student_register.php');
      var request = http.MultipartRequest('POST', uri)
        ..fields['username'] = _usernameController.text
        ..fields['password'] = _passwordController.text
        ..fields['prn'] = _prnController.text
        ..fields['email'] = _emailController.text
        ..fields['uuid'] = studentUuid
        ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          // Save the student data locally using DatabaseHelper
          await DatabaseHelper.saveStudent({
            'username': _usernameController.text,
            'prn': _prnController.text,
            'email': _emailController.text,
            'uuid': studentUuid,
          });

          setState(() {
            _usernameController.clear();
            _passwordController.clear();
            _prnController.clear();
            _emailController.clear();
            _image = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student registered successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to register student.')),
          );
        }
      } catch (e) {
        debugPrint('Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Registration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Register a New Student',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
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
                    labelText: 'College Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter an email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
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
                const SizedBox(height: 10),
                TextFormField(
                  controller: _prnController,
                  decoration: const InputDecoration(
                    labelText: 'PRN',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter a PRN' : null,
                ),
                const SizedBox(height: 20),
                _image != null
                    ? Column(
                        children: [
                          const Text('Selected Image:'),
                          const SizedBox(height: 10),
                          Image.file(
                            _image!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ],
                      )
                    : const Text('No image selected'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pick Image'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerStudent,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Register Student'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
