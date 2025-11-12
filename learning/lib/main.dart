import 'package:flutter/material.dart';
import 'package:learning/gradient_container.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
  body: Center(
    child: const GradientContainer(Color.fromARGB(255, 10, 88, 152), Color.fromARGB(255, 33, 25, 106)),
  ),
    ));
  }
}
