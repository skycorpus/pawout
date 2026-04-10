import 'package:flutter/material.dart';

import '../../../core/constants/routes.dart';
import '../../../core/widgets/custom_button.dart';

class WalkStartScreen extends StatelessWidget {
  const WalkStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start Walk')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Ready to head out with your dog?'),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Start now',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.walkActive);
              },
            ),
          ],
        ),
      ),
    );
  }
}
