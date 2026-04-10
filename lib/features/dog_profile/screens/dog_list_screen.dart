import 'package:flutter/material.dart';

class DogListScreen extends StatelessWidget {
  const DogListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Dogs')),
      body: const Center(
        child: Text('Dog profile list will appear here.'),
      ),
    );
  }
}
