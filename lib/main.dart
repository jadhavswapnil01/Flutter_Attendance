import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
import 'screens/student_register.dart';
import 'screens/student_login.dart';
import 'screens/add_class.dart';
import 'helpers/database_helper.dart';
// import 'widgets/custom_button.dart';
import 'screens/teacher_login.dart';
import 'screens/teacher_register.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.school_rounded,
                  size: 100,
                  color: Color(0xFF1976D2),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to Attendance App',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 30),
                // Custom Button Widgets
                CustomButtonWithIcon(
                  text: 'Student Register',
                  icon: Icons.person_add_alt_1,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StudentRegister()),
                    );
                  },
                ),
                CustomButtonWithIcon(
                text: 'Student Login',
                icon: Icons.login,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentLogin()),
                  );
                },
                ),
                CustomButtonWithIcon(
              text: 'Teacher Register',
              icon: Icons.person_add_alt_1, // Add Teacher Register Button
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TeacherRegister()),
                );
              },
            ),
            CustomButtonWithIcon(
              text: 'Teacher Login',
              icon: Icons.person_add_alt_1, // Add Teacher Login Button
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TeacherLogin()),
                );
              },
            ),
                CustomButtonWithIcon(
                  text: 'Add Classes',
                  icon: Icons.class_,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddClassScreen()),
                    );
                  },
                ),
                CustomButtonWithIcon(
                  text: 'View All Students',
                  icon: Icons.list_alt,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StudentsList()),
                    );
                  },
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Button with Icon
class CustomButtonWithIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const CustomButtonWithIcon({
    required this.text,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
          backgroundColor: Colors.white, // Changed to white
          side: const BorderSide(color: Color(0xFF1976D2), width: 2), // Optional border
        ),
        icon: Icon(icon, size: 24, color: const Color(0xFF1976D2)), // Icon color updated
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1976D2), // Text color updated
          ),
        ),
      ),
    );
  }
}


// Students List Screen
class StudentsList extends StatelessWidget {
  const StudentsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stored Students'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.fetchAllStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No students found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final student = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: ListTile(
                  title: Text(student['username']),
                  subtitle: Text('PRN: ${student['prn']}\nEmail: ${student['email']}'),
                  leading: const Icon(Icons.person, color: Color(0xFF1976D2)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
