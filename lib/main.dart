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
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color.fromARGB(255, 238, 98, 88)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color.fromARGB(255, 238, 98, 88), width: 2.0),
          ),
          prefixIconColor: Colors.black,
        ),
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
      body: Container(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Icon(
                    Icons.school_rounded,
                    size: 120,
                    color: Color(0xFF673AB7),
                  ),
                  const SizedBox(height: 0),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'W',
                          style: TextStyle(
                            fontSize: 31,
                            fontWeight: FontWeight.bold,
                            color:Color(0xFF673AB7),
                          ),
                        ),
                        TextSpan(
                          text: 'elcome to Attend',
                          style: TextStyle(
                            fontSize: 26.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF673AB7),
                          ),
                        ),
                        TextSpan(
                          text: 'ance App',
                          style: TextStyle(
                            fontSize: 26.9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF673AB7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 75),
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
      
      {
        'text': RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Student',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF673AB7),
                ),
              ),
              TextSpan(
                text: ' Regis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF673AB7),
                ),
              ),
              TextSpan(
                text: 'ter',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF673AB7),
                ),
              ),
            ],
          ),
        ),
        'icon': Icons.person_add_alt_1,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StudentRegister()),
          );
        }
      },
      {
        'text': 'Student Login',
        'icon': Icons.login,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StudentLogin()),
          );
        }
      },
      {
        'text': 'Teacher Register',
        'icon': Icons.person_add_alt_1,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TeacherRegister()),
          );
        }
      },
      {
        'text': 'Teacher Login',
        'icon': Icons.person,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TeacherLogin()),
          );
        }
      },
      {
        'text': 'Add Classes',
        'icon': Icons.class_,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddClassScreen()),
          );
        }
      },
      {
        'text': 'Students List',
        'icon': Icons.list_alt,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StudentsList()),
          );
        }
      },
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
                    border: Border.all(
                        color: const Color.fromARGB(255, 0, 0, 0), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(button['icon'] as IconData,
                          color: const Color(0xFF673AB7)),
                      const SizedBox(width: 10),
                      button['text'] is String
                          ? Text(
                              button['text'] as String,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF673AB7),
                              ),
                            )
                          : button['text'] as Widget,
                    ],
                  ),
                ),
              ),
            ))
        .toList();
  }
}

class StudentsList extends StatelessWidget {
  const StudentsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 10,
        title: const Text(
          'Stored Students',
          style: TextStyle(
            color: Color(0xFF673AB7),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF673AB7)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.fetchAllStudents(),
        builder: (
          context,
          snapshot,
        ) {
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
                  subtitle: Text(
                      'PRN: ${student['prn']}\nEmail: ${student['email']}'),
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
