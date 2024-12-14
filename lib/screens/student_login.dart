import 'package:flutter/material.dart';
import '../widgets/custom_input_field.dart'; // Path where CustomInputField is saved
import '../widgets/custom_button.dart';
// import '../services/api_service.dart';

class StudentLogin extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  StudentLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            CustomInputField(controller: usernameController, label: 'Username'),
            CustomInputField(controller: passwordController, label: 'Password', isPassword: true),
            CustomButton(
              text: 'Login',
              onPressed: () async {
                // var response = await ApiService.loginStudent({
                //   'username': usernameController.text,
                //   'password': passwordController.text,
                // });
                // if (response['status'] == 'success') {
                //   Navigator.pushReplacementNamed(context, '/student_dashboard');
                // } else {
                //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
                // }
              },
            ),
          ],
        ),
      ),
    );
  }
}
