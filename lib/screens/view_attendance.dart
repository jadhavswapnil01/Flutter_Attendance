import 'package:flutter/material.dart';

class ViewAttendance extends StatelessWidget {
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
            Text(
              'Subject: $subjectCode - $subjectName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Class: $className',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Lecture Type: $lectureType',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              'Attendance Info:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Placeholder for attendance data
            Expanded(
              child: ListView(
                children: const [
                  Text('Date: 2024-12-01 - P'),
                  Text('Date: 2024-12-02 - A'),
                  // Add actual attendance data here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
