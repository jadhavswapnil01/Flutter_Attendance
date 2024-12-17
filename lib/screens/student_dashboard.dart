import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentDashboard extends StatefulWidget {
  final String uuid; // Pass UUID from login
  const StudentDashboard({Key? key, required this.uuid}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List<String> subjects = [];
  String message = '';

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    const url = 'https://0d58-106-210-148-154.ngrok-free.app/attendance_api/get_subjects.php'; // Replace with your XAMPP IP

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({'uuid': widget.uuid}),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        setState(() {
          subjects = List<String>.from(responseData['subjects']);
        });
      } else {
        setState(() {
          message = responseData['message'];
        });
      }
    } catch (e) {
      setState(() {
        message = 'Failed to fetch subjects. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: subjects.isNotEmpty
            ? ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    onPressed: () {
                      // Navigate to the next page or perform action for the subject
                      debugPrint('Subject Code: ${subjects[index]}');
                    },
                    child: Text(subjects[index]),
                  );
                },
              )
            : Center(
                child: Text(
                  message.isNotEmpty ? message : 'Loading subjects...',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
      ),
    );
  }
}
