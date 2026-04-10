import 'package:flutter/material.dart';

import '../../../core/constants/routes.dart';
import '../../../core/widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PawOut')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Dog walking app starter structure',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Login',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: 'My Dogs',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.dogList),
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: 'Start Walk',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.walkStart),
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: 'Ranking',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.ranking),
            ),
          ],
        ),
      ),
    );
  }
}
