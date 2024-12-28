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
                  const SizedBox(height: 90),
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
                  const SizedBox(height: 85),
                  SizedBox(
                    height: 500, // Adjust height as needed
                    child: _buildButtonGrid(context),
                  ),
                  
                ],
                
              ),
              
            ),
            
          ),
          
        ),
        
      ),
      
    );
    
  }

  Widget _buildButtonGrid(BuildContext context) {
    final buttonData = [
      {
        'text': 'Student Register',
        'icon': Icons.person_add_alt_1,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StudentRegister()),
          );
        },
      },
      {
        'text': 'Student Login',
        'icon': Icons.login,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StudentLogin()),
          );
        },
      },
      {
        'text': 'Teacher Register',
        'icon': Icons.person_add_alt_1,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TeacherRegister()),
          );
        },
      },
      {
        'text': 'Teacher Login',
        'icon': Icons.person,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TeacherLogin()),
          );
        },
      },
      {
        'text': 'Add Classes',
        'icon': Icons.class_,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddClassScreen()),
          );
        },
      },
      {
        'text': 'Students List',
        'icon': Icons.list_alt,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StudentsList()),
          );
        },
      },
    ];

    return GridView.builder(
      itemCount: buttonData.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
        crossAxisSpacing: 16.0, // Horizontal spacing between buttons
        mainAxisSpacing: 16.0, // Vertical spacing between buttons
        childAspectRatio: 2, // Width to height ratio of each button
      ),
      itemBuilder: (context, index) {
        final button = buttonData[index];
        return _buildGridButton(
          context,
          text: button['text'] as String,
          icon: button['icon'] as IconData,
          onPressed: button['onPressed'] as VoidCallback,
        );
      },
    );
  }

  // Function to build individual grid buttons
  Widget _buildGridButton(BuildContext context,
    {required String text,
    required IconData icon,
    required VoidCallback onPressed}) {
  return InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(15),
    splashColor: const Color(0xFF673AB7).withAlpha(50),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF673AB7), width: 1.5),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 30, // Reduced size for the icon
            color: const Color(0xFF673AB7),
          ),
          const SizedBox(height: 5), // Reduced spacing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14, // Reduced font size
                fontWeight: FontWeight.w600,
                color: Color(0xFF673AB7),
              ),
            ),
          ),
        ],
      ),
    ),
  );
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
