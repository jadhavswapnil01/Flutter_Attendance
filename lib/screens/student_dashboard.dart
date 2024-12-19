import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

class StudentDashboard extends StatefulWidget {
  final String uuid; // Pass UUID from login
  const StudentDashboard({Key? key, required this.uuid}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> theorySubjects = [];
  List<Map<String, dynamic>> tutorialSubjects = [];
  List<Map<String, dynamic>> labSubjects = [];
  String message = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    const url =
        '${APIConstants.baseUrl}/attendance_api/get_student_dashboard_data.php'; // Replace with your actual API endpoint

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({'uuid': widget.uuid}),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        List subjects = responseData['subjects'];

        // Organize subjects by lec_type
        setState(() {
  // Cast subjects to List<Map<String, dynamic>> for proper type matching
  final List<Map<String, dynamic>> formattedSubjects = List<Map<String, dynamic>>.from(subjects);

  // Filter the subjects by lecture type
  theorySubjects = formattedSubjects
      .where((subject) => subject['lec_type'].contains('Theory'))
      .toList();
  tutorialSubjects = formattedSubjects
      .where((subject) => subject['lec_type'].contains('Tutorial'))
      .toList();
  labSubjects = formattedSubjects
      .where((subject) => subject['lec_type'].contains('Lab'))
      .toList();
});

      } else {
        setState(() {
          message = responseData['message'];
        });
      }
    } catch (e) {
      setState(() {
        message = 'Failed to fetch data. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: const Color(0xFF1976D2),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Theory'),
            Tab(text: 'Tutorial'),
            Tab(text: 'Lab'),
          ],
        ),
      ),
      body: message.isNotEmpty
          ? Center(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSubjectList(theorySubjects),
                _buildSubjectList(tutorialSubjects),
                _buildSubjectList(labSubjects),
              ],
            ),
    );
  }

  Widget _buildSubjectList(List<Map<String, dynamic>> subjects) {
    if (subjects.isEmpty) {
      return const Center(
        child: Text(
          'No subjects available.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ElevatedButton(
            onPressed: () {
              debugPrint('Subject Selected: ${subject['subject_name']}');
              // Add navigation or actions as needed
            },
            child: Text(subject['subject_name']),
          ),
        );
      },
    );
  }
}
