import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({super.key});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _subjectCodesController = TextEditingController();
  bool _isLoading = false;
  String? _responseMessage;

  Future<void> addClass() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://f3a3-2402-3a80-1aa3-6d5-31c6-a80a-9a5-c1a9.ngrok-free.app/attendance_api/add_class.php'),
      body: {
        'class_name': _classNameController.text,
        'subject_codes': _subjectCodesController.text,
      },
    );

    setState(() {
      _isLoading = false;
      if (response.statusCode == 200) {
        _classNameController.text="";
        _subjectCodesController.text="";
        final responseData = response.body;
        _responseMessage = responseData.contains('"success":true')
            ? 'Class added successfully!'
            : 'Failed To Add Class.';
      } else {
        _responseMessage = 'Error: Unable to connect to server.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Class')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _classNameController,
              decoration: InputDecoration(labelText: 'Class Name'),
            ),
            TextField(
              controller: _subjectCodesController,
              decoration: InputDecoration(
                labelText: 'Subject Codes (comma-separated)',
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: addClass,
                    child: Text('Add Class'),
                  ),
            if (_responseMessage != null) ...[
              SizedBox(height: 20),
              Text(
                _responseMessage!,
                style: TextStyle(
                  color: _responseMessage!.contains('successfully')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
