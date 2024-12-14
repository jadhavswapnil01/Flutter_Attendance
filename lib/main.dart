import 'package:flutter/material.dart';
import 'screens/student_register.dart';
import 'screens/student_login.dart';
import 'widgets/custom_button.dart';
// import 'screens/teacher_register.dart';
// import 'screens/teacher_login.dart';
// import 'screens/add_classes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(text: 'Student Register', onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => StudentRegister()));
            }),
            CustomButton(text: 'Student Login', onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => StudentLogin()));
            }),
            // CustomButton(text: 'Teacher Register', onPressed: () {
            //   Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherRegister()));
            // }),
            // CustomButton(text: 'Teacher Login', onPressed: () {
            //   Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherLogin()));
            // }),
            // CustomButton(text: 'Add Classes', onPressed: () {
            //   Navigator.push(context, MaterialPageRoute(builder: (_) => AddClasses()));
            // }),
          ],
        ),
      ),
    );
  }
}
