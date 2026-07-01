// lib/login_page.dart

import 'package:flutter/material.dart';
// 1. THIS IS THE IMPORT LINK WE TALKED ABOUT:
import 'registration_page.dart'; 

class SafeEntryLoginRoom extends StatefulWidget {
  const SafeEntryLoginRoom({super.key});

  @override
  State<SafeEntryLoginRoom> createState() => _SafeEntryLoginRoomState();
}

class _SafeEntryLoginRoomState extends State<SafeEntryLoginRoom> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordHidden = true;
  String _loginErrorMessage = "";

  void _executeLoginCheck() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // Your testing credentials check
    if (username == "Neshbii" && password == "Vision2030") {
      setState(() {
        _loginErrorMessage = ""; 
      });

      _usernameController.clear();
      _passwordController.clear();

      // 2. THIS IS THE NAVIGATION CODE: This physically pushes the screen forward!
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VisitorRegistryRoom()),
      );
    } else {
      setState(() {
        _loginErrorMessage = "❌ Access Denied! Incorrect username or password.";
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('SafeEntry Portal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A237E),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.shield, size: 80, color: Color(0xFF1A237E)),
              const SizedBox(height: 24),
              const Text(
                'Guard Portal Terminal',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Guard Username",
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Color(0xFF1A237E)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _isPasswordHidden,
                decoration: InputDecoration(
                  labelText: "Guard Password",
                  fillColor: Colors.white,
                  filled: true,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF1A237E)),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordHidden ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _executeLoginCheck, // Triggers your validation & navigation check!
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white, 
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('INITIALIZE SYSTEM ENGINE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 24),
              Text(
                _loginErrorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
