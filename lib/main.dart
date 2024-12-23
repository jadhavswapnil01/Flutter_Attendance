import 'package:flutter/material.dart';
import 'screens/add_class.dart';
import 'screens/student_login.dart';
import 'screens/student_register.dart';
import 'screens/teacher_login.dart';
import 'screens/teacher_register.dart';
import 'helpers/database_helper.dart';
import 'package:untitled4/screens/background_scaffold.dart';

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
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF673AB7),
          secondary: const Color(0xFF9575CD),
        ),
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
    return BackgroundScaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF673AB7), Color(0xFF9575CD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        // decoration: const BoxDecoration(
        //   gradient: LinearGradient(
        //     //colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //   ),
        // ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.school_rounded,
                    size: 120,
                    color: Color(0xFF673AB7),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome to Attendance App',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF673AB7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ..._buildButtonList(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }

  List<Widget> _buildButtonList(BuildContext context) {
    final buttonData = [
      {'text': 'Student Register', 'icon': Icons.person_add_alt_1, 'onPressed': () {Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => StudentRegister()),
                              );}},
      {'text': 'Student Login', 'icon': Icons.login, 'onPressed': () {Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const StudentLogin()),
                              );}},
      {'text': 'Teacher Register', 'icon': Icons.person_add_alt_1, 'onPressed': () { Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => TeacherRegister()),
                              );}},
      {'text': 'Teacher Login', 'icon': Icons.person, 'onPressed': () {Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => TeacherLogin()),
                              );
}},
      {'text': 'Add Classes', 'icon': Icons.class_, 'onPressed': () {Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AddClassScreen()),
                              );
}},
      {'text': 'Students List', 'icon': Icons.list_alt, 'onPressed': () {Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const StudentsList()),
                              );}},
    ];

    return buttonData
        .map((button) => Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: GestureDetector(
                onTap: button['onPressed'] as VoidCallback,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(0, 184, 89, 213),
                    border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 255, 250, 250).withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(button['icon'] as IconData, color: const Color(0xFF673AB7)),
                      const SizedBox(width: 10),
                      Text(
                        button['text'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF673AB7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ))
        .toList();

        
  }
  
}
// Students List Screen remains unchanged
class StudentsList extends StatelessWidget {
  const StudentsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: const Text('Stored Students'),
        backgroundColor: const Color(0xFF673AB7),
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
