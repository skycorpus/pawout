import 'package:flutter/material.dart';

class WalkHistoryScreen extends StatelessWidget {
  const WalkHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Walk History')),
      body: const Center(
        child: Text('Walk history screen.'),
      ),
    );
  }
}
