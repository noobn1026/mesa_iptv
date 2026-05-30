import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool fullScreen;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFe50914)),
              child: const Text('Try Again'),
            ),
          ],
        ],
      ),
    );

    if (fullScreen) {
      return Scaffold(
        backgroundColor: const Color(0xFF0a0a0a),
        body: child,
      );
    }

    return child;
  }
}