import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:untitled4/screens/background_scaffold.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';


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
  final TextEditingController _ssidController = TextEditingController();
  // static const platform = MethodChannel('com.example.untitled4/lowlet_hightx');
  late String _generatedUuid;
   String? _selectedChannel; 

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
  String? hotspotSSID;

  @override
  void initState() {
    super.initState();
    fetchClasses();
    checkHotspotStatus();
    // fetchHotspotSSID();
    fetchSSIDFromDatabase();
    
  }
Future<String?> fetchSSIDFromDatabase() async {
  final response = await http.post(
    Uri.parse('${APIConstants.baseUrl}/htdocs/attendance_api/get_hotspot_ssid.php'),
    body: {'email': widget.email},
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['success'] && data['ssid'] != null) {
      _ssidController.text =hotspotSSID = data['ssid'];
      return data['ssid']; // Return the SSID from the database
    }
  }
  return null; // Return null if no SSID found
}



Future<void> checkHotspotStatus() async {
  bool isHotspotEnabled = await WiFiForIoTPlugin.isWiFiAPEnabled();
  if (!isHotspotEnabled) {
    // Delay to ensure UI is built before showing the snackbar
    Future.delayed(Duration(milliseconds: 700), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please turn on Hotspot for online attendance to work.",
            style: TextStyle(fontSize: 16),
          ),
          duration: Duration(seconds: 5),
        ),
      );
    });
  }
}

Future<void> updateHotspotSSIDInDatabase(String ssid) async {
  final response = await http.post(
    Uri.parse('${APIConstants.baseUrl}/htdocs/attendance_api/update_hotspot_ssid.php'),
    body: {
      'email': widget.email,
      'ssid': ssid,
    },
  );
}

  Future<void> fetchClasses() async {
    final response = await http.get(Uri.parse(
        '${APIConstants.baseUrl}/htdocs/attendance_api/get_classes.php'));
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
        '${APIConstants.baseUrl}/htdocs/attendance_api/get_subjectnames_teacher.php?class_id=$classId'));
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
        '${APIConstants.baseUrl}/htdocs/attendance_api/get_lecture_types.php?subject_id=$subjectId'));

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
        '${APIConstants.baseUrl}/htdocs/attendance_api/get_subjectcodes_teacher.php?subject_id=$subjectId'));

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
    if (hotspotSSID == null || hotspotSSID!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please provide the Hotspot SSID to proceed.")),
      );
      setState(() => _isLoading = false);
      return;
    }
    loc.Location location = loc.Location();
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
      Uri.parse('${APIConstants.baseUrl}/htdocs/attendance_api/create_classroom.php'),
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

  Future<bool> updateUUID(String email, String uuid) async {
  final url = Uri.parse("${APIConstants.baseUrl}/htdocs/attendance_api/update_uuid.php"); // Replace with your server URL

  try {
    final response = await http.post(
      url,
      body: {
        'email': email,
        'uuid': uuid,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        print("UUID updated successfully.");
        return true;
      } else {
        print("Error: ${data['message']}");
        return false;
      }
    } else {
      print("Server error: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("Exception occurred: $e");
    return false;
  }
}
  Future<void> toggleOnlineAttendance() async {
    // Check and request necessary permissions
  final List<Permission> requiredPermissions = [
    Permission.location,
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothAdvertise,
    Permission.bluetoothConnect,
    Permission.camera,
    Permission.storage, // For Android 10 and below
    Permission.manageExternalStorage, // For Android 11+
  ];

  // Request all permissions
  Map<Permission, PermissionStatus> statuses = await requiredPermissions.request();

  // Check if any permission is denied
  bool allPermissionsGranted = statuses.values.every((status) => status.isGranted);
  if (!allPermissionsGranted) {
    // Show a popup or navigate to settings if permissions are denied
    // showError('Please grant all required permissions.');
    return;
  }
    if (_selectedChannel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a beacon configuration first.")),
      );
      return;
    }

    final newStatus = _isAttendanceActive ? 'inactive' : 'active';
    final selectedClassName = classes
        .firstWhere((classItem) =>
            classItem['id'].toString() == selectedClassId)['class_name'];

    final response = await http.post(
      Uri.parse('${APIConstants.baseUrl}/htdocs/attendance_api/update_attendance_status.php'),
      body: {
        'class_name': selectedClassName,
        'subject_code': subjectCode,
        'lec_type': selectedLectureType,
        'status': newStatus,
      },
    );

    final data = json.decode(response.body);
    if (data['success']) {
      if (!_isAttendanceActive) {
        _generatedUuid = _generateUuid();
        // print(_generatedUuid);
        final beaconStarted = await _startBeacon(_selectedChannel!, _generatedUuid);

        if (!beaconStarted) {
          await http.post(
            Uri.parse('${APIConstants.baseUrl}/htdocs/attendance_api/update_attendance_status.php'),
            body: {
              'class_name': selectedClassName,
              'subject_code': subjectCode,
              'lec_type': selectedLectureType,
              'status': 'inactive',
            },
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to start beacon. Attendance deactivated.")),
          );
          return;
        }

        // Update UUID in the database
      await updateUUID(widget.email, _generatedUuid);
      } else {
        await _stopBeacon();
      }

      setState(() {
        _isAttendanceActive = !_isAttendanceActive;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    }
  }

  Future<bool> _startBeacon(String channel, String uuid) async {
    try {
      final result = await MethodChannel(channel).invokeMethod('startBeacon', {"uuid": uuid});
      return result == true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _stopBeacon() async {
    try {
      await MethodChannel('com.example.untitled4/lowlet_hightx').invokeMethod('stopBeacon');
    } catch (e) {
      print(e);
    }
  }

  String _generateUuid() {
    final uuid = Uuid();
    return uuid.v4();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(
            color: Color(0xFF673AB7),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF673AB7)),
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
    child: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Optional for better alignment
        children: [
          const SizedBox(height: 80),
          const Text(
            'Create Classroom',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          buildCustomTextField('Enter Classroom Number', _classroomnumberController),
          const SizedBox(height: 30),
          buildCustomDropdown(
           hintText:  'Select Class',
           value:  selectedClassId,
           items:  classes.map((classItem) {
              return DropdownMenuItem(
                value: classItem['id'].toString(),
                child: Text(classItem['class_name']),
              );
            }).toList(),
           onChanged: (value) {
              setState(() {
                selectedClassId = value;
                selectedSubjectNameId = null; // Reset dependent dropdown
                selectedLectureType = null;  // Reset dependent dropdown
                fetchSubjectNames(value!);
              });
            },
          ),
          const SizedBox(height: 30),
          buildCustomDropdown(
           hintText:  'Select Subject',
           value:  selectedSubjectNameId,
           items:  subjectnames.map((subject) {
              return DropdownMenuItem(
                value: subject['id'].toString(),
                child: Text(subject['subject_name'], overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10)),
              );
            }).toList(),
          onChanged:  (value) {
              setState(() {
                selectedSubjectNameId = value;
                selectedLectureType = null;  // Reset dependent dropdown
                fetchLectureTypes(value!);
                fetchSubjectCode(value);
              });
            },
          ),
          const SizedBox(height: 30),
          TextFormField(
            enabled: false,
            controller: _subjectcodeController,
            decoration: InputDecoration(
              labelText: 'Subject Code',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 30),
          buildCustomDropdown(
           hintText:  'Select Lecture Type',
           value:  selectedLectureType,
           items:  lectureTypes.map((lecType) {
              return DropdownMenuItem(
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
          const SizedBox(height: 30),
          Center(
  child: ElevatedButton(
    onPressed: createClassroom,
    style: ElevatedButton.styleFrom(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: const Color(0xFF673AB7),
    ),
    child: _isLoading
        ? const CircularProgressIndicator(color: Colors.white)
        : const Text(
            'Create',
            style: TextStyle(fontSize: 16, color: Colors.white),
            textAlign: TextAlign.center,
          ),
  ),
)
        ],
      ),
    ),
  );
}



 Widget _buildBeaconConfigButtons() {
    final configurations = {
      'Low Latency High TX': 'com.example.untitled4/lowlet_hightx',
      'Balanced Latency High TX': 'com.example.untitled4/ballet_hightx',
      'Low Latency Medium TX': 'com.example.untitled4/lowlet_medtx',
      'Balanced Latency Medium TX': 'com.example.untitled4/ballet_medtx',
      'Low Latency Low TX': 'com.example.untitled4/lowlet_lowtx',
      'Balanced Latency Low TX': 'com.example.untitled4/ballet_lowtx',
    };

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      shrinkWrap: true,
      itemCount: configurations.keys.length,
      itemBuilder: (context, index) {
        final configName = configurations.keys.elementAt(index);
        final channel = configurations[configName]!;
        return ElevatedButton(
          onPressed: () async {
            if (_isAttendanceActive) {
              await _stopBeacon(); // Stop the current beacon
              setState(() {
                _isAttendanceActive = false; // Deactivate attendance
              });
            }
            setState(() {
              _selectedChannel = channel; // Select new beacon configuration
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedChannel == channel
                ? Colors.green
                : const Color.fromARGB(255, 255, 255, 255),
          ),
          child: Text(configName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
        );
      },
    );
  }

Widget buildManageAttendanceSection() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        const SizedBox(height: 80),
        const Text(
          'Manage Attendance',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        classDetails.isNotEmpty
            ? Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListTile(
                    title: Text('Class: ${classDetails['Class Name']}'),
                    subtitle: Text('Subject: ${classDetails['Subject Name']}'),
                    trailing: Text(
                      'Lecture: ${classDetails['Lecture Type']}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                ),
              )
            : const Text('No class created yet.'),
       const SizedBox(height: 0),
          _buildBeaconConfigButtons(),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _selectedChannel == null
                ? null
                : () async {
                    await toggleOnlineAttendance();
                    if (_isAttendanceActive) {
                      _startCountdownTimer();
                    } else {
                      _countdownTimer?.cancel();
                      setState(() {
                        _remainingTime =
                            const Duration(minutes: 6, seconds: 7);
                      });
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color(0xFF673AB7),
            ),
            child: Text(
              _isAttendanceActive
                  ? 'Deactivate Online Attendance'
                  : 'Activate Online Attendance',
              style: const TextStyle(fontSize: 13, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          _isAttendanceActive && _remainingTime.inSeconds > 0
              ? Text(
                  'Time Remaining: ${_formatTime(_remainingTime)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                )
              : const SizedBox(),
      ],
    ),
  );
}

Duration _remainingTime = const Duration(minutes: 6, seconds: 7);
Timer? _countdownTimer;

void _startCountdownTimer() {
  _countdownTimer?.cancel();
  _remainingTime = const Duration(minutes: 6, seconds: 7);
  _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (_remainingTime.inSeconds > 0) {
      setState(() {
        _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
      });
    } else {
      timer.cancel();
      setState(() {
        _isAttendanceActive = false;
      });
    }
  });
}

String _formatTime(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return '$minutes:$seconds';
}

@override
void dispose() {
  _countdownTimer?.cancel();
  super.dispose();
}




  Widget buildCustomTextField(String hintText, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent, width: 1),
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

 Widget buildCustomDropdown({
  required String hintText,
  required String? value,
  required List<DropdownMenuItem<String>> items,
  required ValueChanged<String?> onChanged,
}) {
  return DropdownButton<String>(
    value: value,
    hint: Text(hintText),
    isExpanded: true,
    underline: Container(
      height: 1,
      color: Colors.black,
    ),
    items: items,
    onChanged: onChanged,
    style: const TextStyle(fontSize: 16, color: Colors.black),
    borderRadius: BorderRadius.circular(10),
    dropdownColor: Colors.white,
  );
}

}
