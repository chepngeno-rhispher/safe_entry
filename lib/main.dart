import 'package:flutter/material.dart';
//to link with login page
import 'login_page.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SafeEntryLoginRoom(),//boots upp week 2
  ));
}

class MyFirstMobileApp extends StatelessWidget {
  const MyFirstMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Week 1 Assignment',
      home: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // Clean Off-White Canvas
        appBar: AppBar(
          title: const Text(
            'Hello World Mobile App', 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF1A237E), // Deep Security Navy Blue
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // The Security Shield Lock Visual Anchor
                const Icon(
                  Icons.shield, 
                  size: 80, 
                  color: Color(0xFF1A237E), 
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to BIT 4107!',
                  style: TextStyle(
                    fontSize: 28.0, 
                    fontWeight: FontWeight.bold, 
                    color: Color(0xFF1A237E), 
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'First Mobile Application Practice',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0, color: Colors.black54),
                ),
                const SizedBox(height: 40),
                
                // The Safety Highlight Action Button
                ElevatedButton(
                  onPressed: () {
                    debugPrint("Week 1 Security Button Tapped Successfully!");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800), // Safety Orange
                    foregroundColor: Colors.white, 
                    minimumSize: const Size.fromHeight(50), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), 
                    ),
                  ),
                  child: const Text(
                    'INITIALIZE SYSTEM ENGINE', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
