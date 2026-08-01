import 'package:flutter/material.dart';
import 'package:list_with_pagination/earning_screen.dart';
import 'package:list_with_pagination/projects_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Funngro Assignment',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: EarningsScreen(userId: 'user_123', api: ProjectsApi()),
    );
  }
}
