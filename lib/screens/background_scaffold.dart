import 'package:flutter/material.dart';

class BackgroundScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final Widget? floatingActionButton;

  const BackgroundScaffold({
    required this.body,
    this.appBar,
    this.floatingActionButton,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/z.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          body,
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}



