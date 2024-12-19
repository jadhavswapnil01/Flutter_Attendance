import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../helpers/database_helper.dart'; // Adjust as per your structure
import '../screens/student_login.dart';
import 'constants.dart';

class StudentRegister extends StatefulWidget {
  const StudentRegister({super.key});

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
  List<Map<String, dynamic>> _classes = [];
  String? _selectedClassId; // For storing the selected class

  bool _isLoading = false;
  final Uuid uuid = Uuid();
  @override
  void initState() {
    super.initState();
    _fetchClasses(); // Fetch classes when the widget is initialized
  }


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
  Future<void> _fetchClasses() async {
  const url = '${APIConstants.baseUrl}/attendance_api/get_classes.php';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _classes = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    } else {
      throw Exception('Failed to load classes');
    }
  } catch (e) {
    debugPrint('Error fetching classes: $e');
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
      final uri = Uri.parse(
          '${APIConstants.baseUrl}/attendance_api/student_register.php');
      var request = http.MultipartRequest('POST', uri)
        ..fields['username'] = _usernameController.text
        ..fields['password'] = _passwordController.text
        ..fields['prn'] = _prnController.text
        ..fields['email'] = _emailController.text
        ..fields['uuid'] = studentUuid
        ..fields['class_id'] = _selectedClassId ?? '' // Add selected class_id
        ..files.add(await http.MultipartFile.fromPath('image', _image!.path));
        

      try {
        var response = await request.send();
        if (response.statusCode == 200) {
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
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentLogin(),
          ),
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6DD5FA), Color(0xFF2980B9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Student Registration',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _emailController,
                        label: 'College Email',
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _prnController,
                        label: 'PRN',
                        icon: Icons.numbers,
                      ),
                      Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: DropdownButtonFormField<String>(
                        value: _selectedClassId,
                        onChanged: (value) {
                          setState(() {
                            _selectedClassId = value;
                          });
                        },
                        items: _classes
                            .map((classData) => DropdownMenuItem(
                                  value: classData['id'].toString(),
                                  child: Text(
                                    classData['class_name'],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ))
                            .toList(),
                        decoration: InputDecoration(
                          labelText: 'Select Class',
                          labelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                        ),
                        validator: (value) => value == null ? 'Please select a class' : null,
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                        dropdownColor: Colors.white,
                      ),
                    ),

                      const SizedBox(height: 20),
                      _image != null
                          ? Column(
                              children: [
                                const Text(
                                  'Selected Image:',
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _image!,
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'No image selected',
                              style: TextStyle(color: Colors.white),
                            ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Pick Image'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        
                        onPressed: _isLoading ? null :  _registerStudent,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2980B9),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Register Student',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value!.isEmpty ? 'Enter $label' : null,
    );
  }
}
