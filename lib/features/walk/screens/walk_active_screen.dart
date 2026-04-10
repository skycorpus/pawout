import 'package:flutter/material.dart';

class WalkActiveScreen extends StatelessWidget {
  const WalkActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Walking')),
      body: const Center(
        child: Text('Active walk tracking screen.'),
      ),
    );
  }
}
