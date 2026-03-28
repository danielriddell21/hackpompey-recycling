import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TwoScreen extends StatelessWidget {
  const TwoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen 2'),
        backgroundColor: AppTheme.orange100,
      ),
      body: const Center(
        child: Text(
          'This is a placeholder for screen 2.',
          style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF)),
        ),
      ),
    );
  }
}
