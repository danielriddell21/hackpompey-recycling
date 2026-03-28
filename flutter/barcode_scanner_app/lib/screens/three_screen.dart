import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThreeScreen extends StatelessWidget {
  const ThreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen 3'),
        backgroundColor: AppTheme.orange100,
      ),
      body: const Center(
        child: Text(
          'This is a placeholder for screen 3.',
          style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF)),
        ),
      ),
    );
  }
}
