import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'student_dashboard_new.dart';
import 'package:image/image.dart' as img;

class FaceRegistrationScreen extends StatefulWidget {
  final String uuid;
  const FaceRegistrationScreen({Key? key, required this.uuid}) : super(key: key);

  @override
  _FaceRegistrationScreenState createState() => _FaceRegistrationScreenState();
}

class _FaceRegistrationScreenState extends State<FaceRegistrationScreen> {
  File? _image;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _registerFace() async {
    if (_image == null) {
      _showSnackBar("Please capture your face first.", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final compressedBytes = await _compressImage(_image!);
      final faceImage = base64Encode(compressedBytes);

      final response = await http.post(
        Uri.parse('${APIConstants.baseUrl}/attendance_api/register_face.php'),
        body: {'uuid': widget.uuid, 'face_image': faceImage},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        _showSnackBar(data['message'], Colors.green);
        _redirectToDashboard();
      } else {
        _showSnackBar(data['message'] ?? "Registration failed.", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Error during registration: $e", Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<int>> _compressImage(File image) async {
    final bytes = await image.readAsBytes();
    final originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      throw Exception("Failed to decode the image.");
    }

    final maxDimension = 1024;
    final resizedImage = img.copyResize(
      originalImage,
      width: originalImage.width > originalImage.height ? maxDimension : null,
      height: originalImage.height > originalImage.width ? maxDimension : null,
    );

    return img.encodeJpg(resizedImage, quality: 85);
  }

  void _redirectToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDashboardNew(uuid: widget.uuid),
      ),
      (route) => false,
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Face Registration")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.file(
                        _image!,
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Center(
                        child: Text(
                          "No image captured",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Capture Face"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _registerFace,
                icon: const Icon(Icons.save),
                label: Text(_isLoading ? "Registering..." : "Register Face"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
