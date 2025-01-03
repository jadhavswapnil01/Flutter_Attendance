import 'dart:convert';
// import 'dart:ffi';
import 'dart:io';
// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:untitled4/screens/background_scaffold.dart';
// import 'package:untitled4/helpers/database_helper.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled4/screens/student_dashboard.dart';
// import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';



class ViewAttendance extends StatefulWidget {
  final String? uuid;
  final String? subjectName;
  final String? subjectCode;
  final String? className;
  final String? lectureType;
  final String? classroomId=null;

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
  // static const platform = MethodChannel('com.example.untitled4/lowlet_hightx');
  bool isAttendanceActive = false;
  bool isLoading = true;
  String? ssid;
  late int classroomId;
  List<dynamic> attendanceInfo = [];
  String? uuidBluetooth;
  // bool _beaconStatus;

  @override
  void initState() {
    super.initState();
    fetchClassroomStatus();
    fetchAttendanceInfo();
    // fetchSSID(); 
  }

   Future<void> fetchSSID(int classroomId) async {
    
    final response = await http.get(Uri.parse('${APIConstants.baseUrl}/attendance_api/fetch_ssid_Buuid_student.php?classroom_id=$classroomId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // if (data['success']) {
        setState(() {
          ssid = data['ssid'];
          uuidBluetooth = data['uuidBluetooth'];
          // print(uuidBluetooth);
          // print(ssid);
        });
      
      }
    
  }


  

  Future<void> fetchClassroomStatus() async {
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
        // print(classroomId);
        fetchSSID(classroomId);
      });
    } else {
      showError('Failed to fetch classroom status');
    }
  }

 Future<bool> _startScanning(String uuid) async {
  final MethodChannel channel = MethodChannel('com.example.untitled4/lowlet_hightx');
  final Completer<bool> completer = Completer<bool>();

  channel.setMethodCallHandler((MethodCall call) async {
    if (call.method == 'onBeaconFound') {
      final bool result = call.arguments as bool;
      completer.complete(result);
    }
  });

  try {
    await channel.invokeMethod('startScanninguuid', {"uuid": uuid});
  } catch (e) {
    completer.completeError(e);
  }

  return completer.future;
}


  

  Future<void> fetchAttendanceInfo() async {
    try {
      final response = await http.post(
        Uri.parse('${APIConstants.baseUrl}/attendance_api/getAttendanceInfo.php'),
        body: {
          'uuid': widget.uuid,
          'class_name': widget.className,
          'subject_code': widget.subjectCode,
          'lecture_type': widget.lectureType,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success']) {
          setState(() {
            attendanceInfo = data['attendance'];
          });
        } else {
          showError(data['message'] ?? 'Failed to fetch attendance info');
        }
      } else {
        showError('Failed to fetch attendance info (HTTP ${response.statusCode})');
      }
    } catch (e) {
      showError('An error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

 Future<List<int>> _compressImage(File image) async {
  final compressedBytes = await FlutterImageCompress.compressWithFile(
    image.absolute.path,
    quality: 70,
    format: CompressFormat.jpeg,
    minWidth: 1024,  // Resize dimensions if needed
    minHeight: 1024, // Ensure size matches max dimension
  );

  if (compressedBytes == null) {
    throw Exception("Failed to compress the image.");
  }
  
  return compressedBytes;
}


 Future<bool> authenticateFace(BuildContext context, String uuid) async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
showLoadingIndicator(context);
  if (pickedFile == null) {
    hideLoadingIndicator(context);
    showError("No Image Selected");
    return false; // No image captured
  }

  final File image = File(pickedFile.path);

  // Show loading indicator
  // showDialog(
  //   context: context,
  //   barrierDismissible: false,
  //   builder: (_) => const Center(child: CircularProgressIndicator()),
  // );
  
// showLoadingIndicator(context);
  
  try {
    final compressedBytes = await _compressImage(image);
    final faceImage = base64Encode(compressedBytes);

    final response = await http.post(
      Uri.parse('${APIConstants.baseUrl}/attendance_api/verify_face.php'),
      body: {
        'uuid': uuid,
        'face_image': faceImage,
      },
    );

    // Navigator.of(context).pop(); // Dismiss the loading indicator

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['match'] == true;
    } else {
      hideLoadingIndicator(context);
      showError("Error Connecting to the server");
      
      return false;
    }
  } catch (e) {
    // Navigator.of(context).pop(); // Dismiss the loading indicator
    hideLoadingIndicator(context);
    showError("Error during face authentication: $e");
    return false;
  }finally{
    
    hideLoadingIndicator(context);
    
  }
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




// double calculateFaceDistance(Map<String, dynamic> face1, Map<String, dynamic> face2) {
//   final double dx = face1["centerX"] - face2["centerX"];
//   final double dy = face1["centerY"] - face2["centerY"];
//   return sqrt(dx * dx + dy * dy);
// }

 void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

Future<bool> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    if (status.isGranted) {
      return true;
    } else {
      _showSnackBar('Camera permission is required to proceed.');
      return false;
    }
  }


Future<void> markAttendanceWithRSSI(String ssid) async {
  fetchClassroomStatus();
  
if(isAttendanceActive){
   bool hasPermission = await _requestCameraPermission();
      if (!hasPermission) return; // Don't proceed if permission is not granted
  
 
   final bool foundUUID = await _startScanning(uuidBluetooth!);
  //  print(foundUUID); 
  if (foundUUID) {

    final bool faceVerified = await authenticateFace(context,widget.uuid!);
    if (faceVerified) {
      markAttendance();
    
    }else{
     
     showError('Face authentication failed');
      return;
    }

  } else {
    
    showError('You Are Not In The Classroom');
    return;
  }
}else{
  showError('Online attendance is no longer active.');
  return;
}
}

 void _handleBackPress() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDashboard(uuid: widget.uuid!),
      ),
    );
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

      // Fetch updated attendance info after successful marking
      fetchAttendanceInfo();
    } else {
      showError('Failed to mark attendance');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lastAttendance = attendanceInfo.isNotEmpty ? attendanceInfo.last : null;
    final isLastAttendancePresent =
        lastAttendance != null && lastAttendance['status'] == 'P';
 return WillPopScope(
      onWillPop: () async {
        _handleBackPress();
        return false; // Prevent default back action
      },
      child: BackgroundScaffold(
      // appBar: AppBar(
      //   title: const Text('Attendance Details'),
      //   backgroundColor: const Color(0xFF1976D2),
      // ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
            : SingleChildScrollView(
         child : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
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
                  const SizedBox(height: 20),
                  const Text(
                    'Attendance Info:',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  attendanceInfo.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true, // Prevent ListView from taking unnecessary space
                          physics: const NeverScrollableScrollPhysics(), // Disable scrolling if not needed
                          itemCount: attendanceInfo.length,
                          itemBuilder: (context, index) {
                            final attendance = attendanceInfo[index];
                            final isPresent = attendance['status'] == 'P';
                            final isLastCard = index == attendanceInfo.length - 1;
                              

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 4), // Reduced margin here
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        isPresent ? Colors.green : Colors.red,
                                    child: Text(
                                      attendance['status'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'Date: ${attendance['date']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: isLastCard && isAttendanceActive
                                      ? const Text(
                                          'Online attendance active for this record.',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                              );
                            },
                          )
                        : const Center(child: Text('No attendance records found.')),
                  
                ],
              ),
            ),
    ),
      floatingActionButton: isAttendanceActive && !isLastAttendancePresent
          ? FloatingActionButton.extended(
              onPressed: () async {
                // fetchClassroomStatus();
                // fetchAttendanceInfo();
                // print(ssid);
                final passingSsid = ssid;
                if (passingSsid!.isEmpty) {
                showError('SSID not provided.');
                return;
                } // Fetch from the database
                await markAttendanceWithRSSI(passingSsid);
              },
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
    ),
 );
  }
}
