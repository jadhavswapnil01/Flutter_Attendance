import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class TeacherDashboard extends StatefulWidget {
  final String email;

  const TeacherDashboard({Key? key, required this.email}) : super(key: key);

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final _classroomnumberController = TextEditingController();
  List classes = [];
  List subjects = [];
  List<String> lectureTypes = [];
  String? selectedClassId;
  String? selectedSubjectId; // Subject ID
  String? selectedLectureType;

  bool _isLoading = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    final response = await http.get(Uri.parse(
        'https://0d58-106-210-148-154.ngrok-free.app/attendance_api/get_classes.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        classes = data;
      });
    } else {
      setState(() {
        _message = "Failed to load classes";
      });
    }
  }

  Future<void> fetchSubjects(String classId) async {
    final response = await http.get(Uri.parse(
        'https://0d58-106-210-148-154.ngrok-free.app/attendance_api/get_subjects_teacher.php?class_id=$classId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          subjects = data['subjects'];
          selectedSubjectId = null;
          lectureTypes = [];
          selectedLectureType = null;
        });
      }
    }
  }

  Future<void> fetchLectureTypes(String subjectId) async {
    final response = await http.get(Uri.parse(
        'https://0d58-106-210-148-154.ngrok-free.app/attendance_api/get_lecture_types.php?subject_id=$subjectId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          lectureTypes = data['lec_types'].split(',');
          selectedLectureType = null;
        });
      }
    }
  }

  Future<void> createClassroom() async {
    setState(() => _isLoading = true);
    Location location = Location();
    var hasPermission =
        await location.serviceEnabled() || await location.requestService();

    if (!hasPermission) {
      setState(() {
        _message = "Location permission denied";
        _isLoading = false;
      });
      return;
    }

    final userLocation = await location.getLocation();

    final response = await http.post(
      Uri.parse(
          'https://0d58-106-210-148-154.ngrok-free.app/attendance_api/create_classroom.php'),
      body: {
        'email': widget.email,
        'class_name': selectedClassId,
        'subject_id': selectedSubjectId,
        'lec_type': selectedLectureType,
        'latitude': userLocation.latitude.toString(),
        'longitude': userLocation.longitude.toString(),
        'classroom_number':_classroomnumberController.text,
      },
    );

    final data = json.decode(response.body);
    setState(() {
      _isLoading = false;
      _message = data['message'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Classroom',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
                TextFormField(
                  controller: _classroomnumberController,
                  decoration: InputDecoration(
                    labelText: 'Enter Classroom Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter Classroom number' : null,
                ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              hint: const Text('Select Class'),
              isExpanded: true,
              value: selectedClassId,
              items: classes.map<DropdownMenuItem<String>>((classItem) {
                return DropdownMenuItem<String>(
                  value: classItem['id'].toString(),
                  child: Text(classItem['class_name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedClassId = value;
                  subjects = [];
                  selectedSubjectId = null;
                  lectureTypes = [];
                  selectedLectureType = null;
                });
                fetchSubjects(value!);
              },
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              hint: const Text('Select Subject'),
              isExpanded: true,
              value: selectedSubjectId,
              items: subjects.map<DropdownMenuItem<String>>((subject) {
                return DropdownMenuItem<String>(
                  value: subject['id'].toString(),
                  child: Text(subject['subject_name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSubjectId = value;
                  lectureTypes = [];
                  selectedLectureType = null;
                });
                fetchLectureTypes(value!);
              },
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              hint: const Text('Select Lecture Type'),
              isExpanded: true,
              value: selectedLectureType,
              items: lectureTypes.map<DropdownMenuItem<String>>((lecType) {
                return DropdownMenuItem<String>(
                  value: lecType,
                  child: Text(lecType),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLectureType = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: (_isLoading ||
                        selectedClassId == null ||
                        selectedSubjectId == null ||
                        selectedLectureType == null)
                    ? null
                    : createClassroom,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create'),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                _message,
                style: TextStyle(
                  color: _message.contains('Successful')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
