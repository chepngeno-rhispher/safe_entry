// lib/login_screen.dart

import 'package:flutter/material.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordHidden = true;
  String _loginErrorMessage = '';

  final String _validUsername = 'Neshbi';
  final String _validPassword = 'Vision2030';

  void _executeLoginCheck() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _loginErrorMessage = 'Please enter both username and password';
      });
      return;
    }

    if (username == _validUsername && password == _validPassword) {
      setState(() {
        _loginErrorMessage = '';
      });
      _usernameController.clear();
      _passwordController.clear();
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegistrationScreen()),
      );
    } else {
      setState(() {
        _loginErrorMessage = 'Access Denied! Incorrect username or password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(  // ← ADD THIS!
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Icon
                  const Icon(
                    Icons.security_rounded,
                    size: 70,  // ← Made smaller
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),  // ← Reduced
                  const Text(
                    'SafeEntry',
                    style: TextStyle(
                      fontSize: 28,  // ← Made smaller
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Visitor Management System',
                    style: TextStyle(
                      fontSize: 14,  // ← Made smaller
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),  // ← Reduced
                  
                  // Card with login form
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),  // ← Reduced
                      child: Column(
                        children: [
                          const Text(
                            'Guard Portal',
                            style: TextStyle(
                              fontSize: 18,  // ← Made smaller
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          const SizedBox(height: 20),  // ← Reduced
                          
                          // Username Field
                          TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              hintText: 'Enter your username',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,  // ← Reduced
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),  // ← Reduced
                          
                          // Password Field
                          TextField(
                            controller: _passwordController,
                            obscureText: _isPasswordHidden,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordHidden
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordHidden = !_isPasswordHidden;
                                  });
                                },
                              ),
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,  // ← Reduced
                              ),
                            ),
                            onSubmitted: (_) => _executeLoginCheck(),
                          ),
                          
                          // Error Message
                          if (_loginErrorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),  // ← Reduced
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 16,  // ← Made smaller
                                  ),
                                  const SizedBox(width: 6),  // ← Reduced
                                  Expanded(
                                    child: Text(
                                      _loginErrorMessage,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,  // ← Made smaller
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          const SizedBox(height: 20),  // ← Reduced
                          
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 44,  // ← Made smaller
                            child: ElevatedButton(
                              onPressed: _executeLoginCheck,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A237E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'INITIALIZE SYSTEM ENGINE',
                                style: TextStyle(
                                  fontSize: 14,  // ← Made smaller
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),  // ← Reduced
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}