import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  final String? text;
  final bool fullScreen;

  const LoadingSpinner({super.key, this.text, this.fullScreen = false});

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFFe50914)),
          if (text != null) ...[
            const SizedBox(height: 12),
            Text(text!, style: const TextStyle(color: Colors.grey)),
          ],
        ],
      ),
    );

    if (fullScreen) {
      return const Scaffold(
        backgroundColor: Color(0xFF0a0a0a),
        body: child,
      );
    }

    return child;
  }
}