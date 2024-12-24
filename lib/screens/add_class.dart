import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:untitled4/screens/background_scaffold.dart';

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({super.key});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _subjectsController = TextEditingController();
  bool _isLoading = false;
  String? _responseMessage;

  Future<void> addClass() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('${APIConstants.baseUrl}/attendance_api/add_class.php'),
      body: {
        'class_name': _classNameController.text,
        'subjects': _subjectsController.text,
      },
    );

    setState(() {
      _isLoading = false;
      if (response.statusCode == 200) {
        
        final responseData = response.body;
        debugPrint('Response Body: ${response.body}');
        _responseMessage = responseData.contains('"success":true')
            ? 'Class and subjects added successfully!' 
            : 'Failed to add class.' ;
      } else {
        _responseMessage = 'Error: Unable to connect to server.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Add Class and Subject',
          style: TextStyle(
            color: Color(0xFF673AB7),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF673AB7)),
      ),
      body: Padding(
        
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 100),
            TextField(
              controller: _classNameController,
              decoration: InputDecoration(labelText: 'Class Name'),
            ),
            TextField(
              controller: _subjectsController,
              decoration: InputDecoration(
                labelText: 'Subjects (Format: (code,name,{types}),(...))',
              ),
              maxLines: 2,
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
