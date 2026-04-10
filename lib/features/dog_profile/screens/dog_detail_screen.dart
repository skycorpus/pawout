import 'package:flutter/material.dart';

class DogDetailScreen extends StatelessWidget {
  const DogDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dog Detail')),
      body: const Center(
        child: Text('Dog detail screen.'),
      ),
    );
  }
}
