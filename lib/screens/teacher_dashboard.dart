import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

class TeacherDashboard extends StatefulWidget {
  final String email;

  const TeacherDashboard({Key? key, required this.email}) : super(key: key);

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final _classroomnumberController = TextEditingController();
  final _subjectcodeController = TextEditingController();
  final PageController _pageController = PageController();

  List classes = [];
  List subjectnames = [];
  List<String> lectureTypes = [];
  String? selectedClassId;
  String? selectedSubjectNameId;
  String? selectedSubjectName;
  String? selectedLectureType;
  String? subjectCode;

  bool _isLoading = false;
  String _message = '';
  Map<String, String> classDetails = {};

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }


  Future<void> fetchClasses() async {
    final response = await http.get(Uri.parse(
        '${APIConstants.baseUrl}/attendance_api/get_classes.php'));

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

  Future<void> fetchSubjectNames(String classId) async {
    final response = await http.get(Uri.parse(
        '${APIConstants.baseUrl}/attendance_api/get_subjectnames_teacher.php?class_id=$classId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          subjectnames = data['subjectnames'];
          selectedSubjectNameId = null;
          selectedSubjectName = null;
          lectureTypes = [];
          selectedLectureType = null;
        });
      }
    }
  }

  Future<void> fetchLectureTypes(String subjectId) async {
    final response = await http.get(Uri.parse(
        '${APIConstants.baseUrl}/attendance_api/get_lecture_types.php?subject_id=$subjectId'));

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

Future<void> fetchSubjectCode(String subjectId) async {
  final response = await http.get(Uri.parse(
        '${APIConstants.baseUrl}/attendance_api/get_subjectcodes_teacher.php?subject_id=$subjectId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          subjectCode = data['subject_code'];
          _subjectcodeController.text=subjectCode!;
        });
      }
    }
  }

 Future<void> createClassroom() async {
  setState(() => _isLoading = true);

  // Ensure location permissions are granted
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

  // Map the selectedSubjectNameId to its actual subject_name
  final subjectName = subjectnames.firstWhere(
    (subject) => subject['id'].toString() == selectedSubjectNameId,
    orElse: () => {'subject_name': null},
  )['subject_name'];

  if (subjectName == null) {
    setState(() {
      _message = "Subject name not found for the selected subject ID";
      _isLoading = false;
    });
    return;
  }

  String selectedClassName = classes
      .firstWhere((classItem) => classItem['id'].toString() == selectedClassId)['class_name'];

  // print("Class ID: $selectedClassName");
  // print("Subject Code: $subjectCode");
  // print("Subject Name: $subjectName"); // Correct subject name used here
  // print("Lecture Type: $selectedLectureType");

  // Make API call to create the classroom
  final response = await http.post(
    Uri.parse(
        '${APIConstants.baseUrl}/attendance_api/create_classroom.php'),
    body: {
      'email': widget.email,
      'class_name': selectedClassName,
      'subject_code': subjectCode,
      'subject_name': subjectName, // Correct name sent instead of ID
      'lec_type': selectedLectureType,
      'latitude': userLocation.latitude.toString(),
      'longitude': userLocation.longitude.toString(),
      'classroom_number': _classroomnumberController.text,
    },
  );

  final data = json.decode(response.body);

  setState(() {
    _isLoading = false;
   classDetails = {
        'Class Name': selectedClassId != null
            ? classes.firstWhere((c) => c['id'].toString() == selectedClassId)['class_name']
            : '',
        'Subject Name': subjectnames.firstWhere((s) => s['id'].toString() == selectedSubjectNameId)['subject_name'],
        'Lecture Type': selectedLectureType ?? '',
        'Classroom Number': _classroomnumberController.text,
        'Subject Code': subjectCode ?? '',
      };
_message = data['message'];
    });

    // Scroll to Section 2
    _pageController.animateToPage(1, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
}


    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
      ),
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Section 1: Create Classroom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Classroom',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _classroomnumberController,
                    decoration: InputDecoration(
                      labelText: 'Enter Classroom Number',
                      border: InputBorder.none, // Remove the default TextField border
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter Classroom number' : null,
                  ),
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
                      fetchSubjectNames(value!);
                    });
                  },
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  hint: const Text('Select Subject'),
                  isExpanded: true,
                  value: selectedSubjectNameId,
                  items: subjectnames.map<DropdownMenuItem<String>>((subject) {
                    return DropdownMenuItem<String>(
                      value: subject['id'].toString(),
                      child: Text(subject['subject_name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSubjectNameId = value;
                      fetchLectureTypes(value!);
                      fetchSubjectCode(value);
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  enabled: false,
                  controller: _subjectcodeController,
                  decoration: InputDecoration(
                    labelText: 'Subject Code',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
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
                const SizedBox(height: 40),
                
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: createClassroom,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black87)
                        : const Text('Create'),
                  ),
                ),
              ],
            ),
          ),

          // Section 2: Manage Attendance
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage Attendance',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (classDetails.isNotEmpty)
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: classDetails.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              '${entry.key}: ${entry.value}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                Center(
                  child: ElevatedButton(
                    onPressed: toggleOnlineAttendance,
                child: Text(_isAttendanceActive
                    ? 'Deactivate Online Attendance'
                    : 'Activate Online Attendance'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  bool _isAttendanceActive = false;

  Future<void> toggleOnlineAttendance() async {
    final newStatus = _isAttendanceActive ? 'inactive' : 'active';
    String selectedClassName = classes
      .firstWhere((classItem) => classItem['id'].toString() == selectedClassId)['class_name'];

    final response = await http.post(
      Uri.parse('${APIConstants.baseUrl}/attendance_api/update_attendance_status.php'),
      body: {
        'class_name': selectedClassName,
        'subject_code': subjectCode,
        'lec_type': selectedLectureType,
        'status': newStatus,
      },
    );

    final data = json.decode(response.body);
    if (data['success']) {
      setState(() {
        _isAttendanceActive = !_isAttendanceActive;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'])),
    );
  }
}

