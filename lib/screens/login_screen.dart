import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isButtonFocused = false;

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    final result = await context.read<AuthProvider>().login(username, password);

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (mounted) {
        context.go('/home');
      }
    } else {
      _showError(result['message'] ?? 'Login failed');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: const Text('Login Failed', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Color(0xFFe50914))),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      body: SafeArea(
        child: Row(
          children: [
            // Logo side
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.tv, size: 100, color: Color(0xFFe50914)),
                    const SizedBox(height: 20),
                    const Text(
                      'MesaIPTV',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sign in to watch your channels',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            // Form side
            Expanded(
              child: Center(
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1e1e1e)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Username field
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1a1a1a),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2a2a2a)),
                        ),
                        child: TextField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                            hintText: 'Username',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Password field
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1a1a1a),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2a2a2a)),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Login button with TV focus
                      Focus(
                        onFocusChange: (focused) {
                          setState(() => _isButtonFocused = focused);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: _isButtonFocused
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFe50914),
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Contact the provider for credentials!',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}