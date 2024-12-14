import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class StudentRegister extends StatefulWidget {
  const StudentRegister({super.key});

  @override
  _StudentRegisterState createState() => _StudentRegisterState();
}

class _StudentRegisterState extends State<StudentRegister> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _prnController = TextEditingController();
  final _emailController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Function to send data and image to the server
  Future<void> _registerStudent() async {
    if (_image == null) {
      print('Please Fill All Details');
      return;
    }

    final uri = Uri.parse('http://10.0.2.2/attendance_api/student_register.php');
    var request = http.MultipartRequest('POST', uri)
      ..fields['username'] = _usernameController.text
      ..fields['password'] = _passwordController.text
      ..fields['prn'] = _prnController.text
      ..fields['email'] = _emailController.text
    // Attach the image file
      ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Student registered successfully');
      } else {
        print('Failed to register student');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _prnController,
              decoration: InputDecoration(labelText: 'PRN'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'College Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerStudent,
              child: Text('Register Student'),
            ),
          ],
        ),
      ),
    );
  }
}
