import 'dart:convert';
import 'dart:math'; // For generating random colors
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'constants.dart';
import 'view_attendance.dart';
import 'package:untitled4/screens/background_scaffold.dart';
import 'student_dashboard_new.dart';

class StudentDashboard extends StatefulWidget {
  final String uuid;
  final String email;
  const StudentDashboard({Key? key, required this.uuid, required this.email}) : super(key: key);

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
  bool isLoading = true; // Add loading flag
  @override
  void initState() {
    
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchStudentData(context);
    
  }

  void _handleBackPress() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDashboardNew(uuid: widget.uuid, email: widget.email),
      ),
    );
  }
void showLoadingIndicator(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
}

void hideLoadingIndicator(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}

  Future<void> fetchStudentData(BuildContext context) async {
    setState(() {
      isLoading = true; // Start loading
    });
    
  // showLoadingIndicator(context);
    final randomDelay = Random().nextDouble() * 6;
      // Delay the API request
      await Future.delayed(Duration(milliseconds: (randomDelay * 1000).toInt()));

    const url = '${APIConstants.baseUrl}/htdocs/attendance_api/get_student_dashboard_data.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({'uuid': widget.uuid}),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        List subjects = responseData['subjects'];

        setState(() {
          final List<Map<String, dynamic>> formattedSubjects =
              List<Map<String, dynamic>>.from(subjects);

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
         isLoading = false; // Stop loading
      } else {
        setState(() {
          message = responseData['message'];
        });
         isLoading = false; // Stop loading
      }
     
    } catch (e) {
      setState(() {
        message = 'Failed to fetch data. Please try again later.';
      });
       isLoading = false; // Stop loading
    }
  }

  Color _getRandomLightColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      210 + random.nextInt(35),
      210 + random.nextInt(35),
      210 + random.nextInt(35),
    );
  }

@override
Widget build(BuildContext context) {
 return WillPopScope(
      onWillPop: () async {
        _handleBackPress();
        return false; // Prevent default back action
      },
      child: BackgroundScaffold(
appBar: AppBar(
  elevation: 0,
  
  title: const Text(
    'Student Dashboard',
    style: TextStyle(fontSize: 22, color: Color(0xFF673AB7), fontWeight: FontWeight.bold),
     // Slightly larger title font.
  ),
   iconTheme: const IconThemeData(color: Color(0xFF673AB7)),
  backgroundColor: Colors.transparent,
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(70), // Adjusted for larger tabs.
    child: TabBar(
      controller: _tabController,
      
      indicator: BoxDecoration(
        color: Color(0xFF673AB7),
        border: Border.all(),
        borderRadius: BorderRadius.circular(15), // Slightly more rounded rectangle for tabs.
      ),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.black,
      labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Larger and bold text for tabs.
      unselectedLabelStyle: const TextStyle(fontSize: 16), // Slightly smaller for unselected tabs.
      tabs: const [
        Tab(text: ' Theory '),
        Tab(text: ' Tutorial '),
        Tab(text: '  Lab  '),
      ],
    ),
  ),
),
    body:isLoading 
    ?   const Center(
              child: CircularProgressIndicator(), // Show loading indicator
            )
        : message.isNotEmpty
        ? Center(
            child: Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          )
        : TabBarView(
            controller: _tabController,
            children: [
              _buildSubjectList(theorySubjects, 'Theory'),
              _buildSubjectList(tutorialSubjects, 'Tutorial'),
              _buildSubjectList(labSubjects, 'Lab'),
            ],
          ),
  ),
 );
}
  Widget _buildSubjectList(List<Map<String, dynamic>> subjects, String lecType) {
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
        final subjectName = subject['subject_name'];
         final subjectCode = subject['subject_code'];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _getRandomLightColor(),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
            ),
            onPressed: () async {
               showLoadingIndicator(context);
    
    
          // print(index + 1);
          // print(lecType);
          // print(subject);
           final randomDelay = Random().nextDouble() * 6;
      // Delay the API request
      await Future.delayed(Duration(milliseconds: (randomDelay * 1000).toInt()));

          final url = '${APIConstants.baseUrl}/htdocs/attendance_api/process_button_click.php';

          try {
            final response = await http.post(
              Uri.parse(url),
              body: jsonEncode({
                'uuid': widget.uuid,
                'button_id': index + 1,
                'lec_type': lecType, // Pass lecture type
              }),
              headers: {'Content-Type': 'application/json'},
            );

            final responseData = jsonDecode(response.body);

            if (responseData['success'] == true) {
               hideLoadingIndicator(context);
              // Pass subjectName and subjectCode to ViewAttendance
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewAttendance(
                    className: responseData['subject']['class_name'],
                    email: widget.email,
                    uuid: widget.uuid,
                    subjectName: subjectName, // Pass the extracted subject name
                    subjectCode: subjectCode, // Pass the extracted subject code
                    lectureType: lecType, // Use the lecture type passed
                  ),
                ),
              );
             
            } else {
              setState(() {
                message = responseData['message'] ?? 'An error occurred.';
              });
              hideLoadingIndicator(context);
            }
            
          } catch (e) {
            setState(() {
              message = 'Network error: $e';
            });
            hideLoadingIndicator(context);
          }
        },
            child: Text(
              subjectName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  
}

