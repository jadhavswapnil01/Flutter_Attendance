import 'package:flutter/material.dart';
import 'register_face.dart';
import 'student_dashboard.dart';
import 'package:untitled4/screens/background_scaffold.dart';

class StudentDashboardNew extends StatelessWidget {
  final String uuid;
  final String email;
  const StudentDashboardNew({Key? key, required this.uuid, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 160),
              const Icon(
                Icons.dashboard_rounded,
                size: 100,
                color: Color(0xFF673AB7),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome to the Student Dashboard',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF673AB7),
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 16.0, // Space between columns
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 1.7, // Space between rows
                  ),
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    final buttons = [
                      {
                        'text': 'Attendance',
                        'icon': Icons.check_circle_outline,
                        'onPressed': () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentDashboard(uuid: uuid, email: email),
                            ),
                          );
                        },
                      },
                      {
                        'text': 'Register Face',
                        'icon': Icons.face_retouching_natural,
                        'onPressed': () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FaceRegistrationScreen(uuid: uuid, email: email),
                            ),
                          );
                        },
                      },
                    ];
                    final button = buttons[index];
                    return _buildGridButton(
                      context,
                      text: button['text'] as String,
                      icon: button['icon'] as IconData,
                      onPressed: button['onPressed'] as VoidCallback,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridButton(
    BuildContext context, {
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(15),
      splashColor: const Color(0xFF673AB7).withAlpha(50),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
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
              size: 27,
              color: const Color(0xFF673AB7),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
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
