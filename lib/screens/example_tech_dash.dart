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
  final TextEditingController _classroomnumberController = TextEditingController();
  final TextEditingController _subjectcodeController = TextEditingController();
  final PageController _pageController = PageController();

  List classes = [];
  List subjectnames = [];
  List<String> lectureTypes = [];
  String? selectedClassId;
  String? selectedSubjectNameId;
  String? selectedLectureType;
  String? subjectCode;
  String _message = '';
  bool _isLoading = false;
  bool _isAttendanceActive = false;
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
    }else {
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

    Location location = Location();
    bool hasPermission = await location.serviceEnabled() || await location.requestService();

    if (!hasPermission) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final userLocation = await location.getLocation();
    final selectedClassName = classes
        .firstWhere((classItem) => classItem['id'].toString() == selectedClassId)['class_name'];
    final selectedSubjectName = subjectnames
        .firstWhere((subject) => subject['id'].toString() == selectedSubjectNameId)['subject_name'];
        

    final response = await http.post(
      Uri.parse('${APIConstants.baseUrl}/attendance_api/create_classroom.php'),
      body: {
        'email': widget.email,
        'class_name': selectedClassName,
        'subject_code': subjectCode,
        'subject_name': selectedSubjectName,
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
        'Class Name': selectedClassName,
        'Subject Name': selectedSubjectName,
        'Lecture Type': selectedLectureType ?? '',
        'Classroom Number': _classroomnumberController.text,
        'Subject Code': subjectCode ?? '',
      };
      _message = data['message'];
    });

    _pageController.animateToPage(1, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          buildCreateClassroomSection(),
          buildManageAttendanceSection(),
        ],
      ),
    );
  }

  Widget buildCreateClassroomSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Create Classroom',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          buildCustomTextField('Enter Classroom Number', _classroomnumberController),
          const SizedBox(height: 20),
          buildCustomDropdown(
            'Select Class',
            selectedClassId,
            classes.map((classItem) {
              return DropdownMenuItem(
                value: classItem['id'].toString(),
                child: Text(classItem['class_name']),
              );
            }).toList(),
            (value) {
              setState(() {
                selectedClassId = value;
                fetchSubjectNames(value!);
              });
            },
          ),
          const SizedBox(height: 20),
          buildCustomDropdown(
            'Select Subject',
            selectedSubjectNameId,
            subjectnames.map((subject) {
              return DropdownMenuItem(
                value: subject['id'].toString(),
                child: Text(subject['subject_name']),
              );
            }).toList(),
            (value) {
              setState(() {
                selectedSubjectNameId = value;
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
                const SizedBox(height: 20),
          buildCustomDropdown(
            'Select Lecture Type',
            selectedLectureType,
            lectureTypes.map((lecType) {
              return DropdownMenuItem(
                value: lecType,
                child: Text(lecType),
              );
            }).toList(),
            (value) {
              setState(() {
                selectedLectureType = value;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: createClassroom,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget buildManageAttendanceSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Manage Attendance',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          classDetails.isNotEmpty
              ? Card(
                  child: ListTile(
                    title: Text('Class: ${classDetails['Class Name']}'),
                    subtitle: Text('Lecture: ${classDetails['Lecture Type']}'),
                  ),
                )
              : const Text('No class created yet.'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: toggleOnlineAttendance,
            child: Text(_isAttendanceActive
                ? 'Deactivate Online Attendance'
                : 'Activate Online Attendance'),
          ),
        ],
      ),
    );
  }

  Widget buildCustomTextField(String hintText, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget buildCustomDropdown(String hintText, String? value, List<DropdownMenuItem<String>> items, ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hintText),
        isExpanded: true,
        underline: const SizedBox(),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
