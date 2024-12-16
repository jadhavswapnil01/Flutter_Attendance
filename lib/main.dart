import 'package:flutter/material.dart';
import 'dart:async'; // For animations

import 'screens/student_register.dart';
import 'screens/student_login.dart';
import 'screens/add_class.dart';
import 'helpers/database_helper.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _animation = ColorTween(
      begin: const Color(0xFFEDE7F6),
      end: const Color(0xFFD1C4E9),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Scaffold(
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_animation.value!, const Color(0xFFEDE7F6)],
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
                      color: Color(0xFF673AB7),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome to Attendance App',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF673AB7),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Buttons arranged in a grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView(
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        children: [
                          CustomAnimatedButton(
                            text: 'Student Register',
                            icon: Icons.person_add_alt_1,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => StudentRegister()),
                              );
                            },
                          ),
                          CustomAnimatedButton(
                            text: 'Student Login',
                            icon: Icons.login,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const StudentLogin()),
                              );
                            },
                          ),
                          CustomAnimatedButton(
                            text: 'Teacher Register',
                            icon: Icons.person_add_alt_1,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => TeacherRegister()),
                              );
                            },
                          ),
                          CustomAnimatedButton(
                            text: 'Teacher Login',
                            icon: Icons.person,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => TeacherLogin()),
                              );
                            },
                          ),
                          CustomAnimatedButton(
                            text: ' Add Classes ',
                            icon: Icons.class_,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AddClassScreen()),
                              );
                            },
                          ),
                          CustomAnimatedButton(
                            text: ' Students List ',
                            icon: Icons.list_alt,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const StudentsList()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom Animated Button
class CustomAnimatedButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const CustomAnimatedButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  @override
  _CustomAnimatedButtonState createState() => _CustomAnimatedButtonState();
}

class _CustomAnimatedButtonState extends State<CustomAnimatedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      onHover: (hovering) {
        setState(() {
          _isHovered = hovering;
        });
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  decoration: BoxDecoration(
    color: _isHovered ? Colors.blue : Colors.white,
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(color: Colors.blue),
  ),
  child: Wrap(
    alignment: WrapAlignment.center,
    spacing: 10, // Space between icon and text
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Icon(
        widget.icon,
        size: 24,
        color: _isHovered ? Colors.white : Colors.blue,
      ),
      Text(
        widget.text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _isHovered ? Colors.white : Colors.blue,
        ),
      ),
    ],
  ),
),

    );
  }
}

// Students List Screen remains unchanged
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
