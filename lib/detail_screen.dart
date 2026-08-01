import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final dynamic detail;
  const DetailScreen({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings Detail')),
      body: Center(child: Text(detail.toString())),
    );
  }
}