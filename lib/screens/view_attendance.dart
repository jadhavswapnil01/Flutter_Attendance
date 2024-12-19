import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

class ViewAttendance extends StatefulWidget {
  final String? uuid;
  final String? subjectName;
  final String? subjectCode;
  final String? className;
  final String? lectureType;

  const ViewAttendance({
    Key? key,
    required this.uuid,
    required this.subjectName,
    required this.subjectCode,
    required this.className,
    required this.lectureType,
  }) : super(key: key);

  @override
  _ViewAttendanceState createState() => _ViewAttendanceState();
}

class _ViewAttendanceState extends State<ViewAttendance> {
  bool isAttendanceActive = false;
  late int classroomId;

  @override
  void initState() {
    super.initState();
    fetchClassroomStatus();
  }

  Future<void> fetchClassroomStatus() async {
    print(widget.className);
    print(widget.subjectCode);
    print(widget.lectureType);
    final response = await http.post(
      Uri.parse('${APIConstants.baseUrl}/attendance_api/getClassroomStatus.php'),
      body: {
        'class_name': widget.className,
        'subject_code': widget.subjectCode,
        'lecture_type': widget.lectureType,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        isAttendanceActive = data['online_attendance_status'] == 'active';
        classroomId = data['classroom_id'];
      });
    } else {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch classroom status')),
      );
    }
  }

  Future<void> markAttendance() async {
    final response = await http.post(
      Uri.parse('${APIConstants.baseUrl}/attendance_api/markAttendance.php'),
      body: {
        'classroom_id': classroomId.toString(),
        'uuid': widget.uuid,
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance marked successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to mark attendance')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Details'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subject: ${widget.subjectCode} - ${widget.subjectName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Class: ${widget.className}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lecture Type: ${widget.lectureType}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              'Attendance Info:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView(
                children: const [
                  Text('Date: 2024-12-01 - P'),
                  Text('Date: 2024-12-02 - A'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isAttendanceActive
          ? FloatingActionButton.extended(
              onPressed: markAttendance,
              label: const Text(
                'Mark Attendance',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.check),
              backgroundColor: const Color(0xFF673AB7),
              elevation: 8,
              splashColor: Colors.purpleAccent,
            )
          : null,
    );
  }
}
