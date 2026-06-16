// lib/main.dart

import 'package:flutter/material.dart';
import 'login_page.dart'; // Links main straight to your gate login file
import 'package:firebase_core/firebase_core.dart'; // Prepares your project engine for cloud features!

void main() async {
  // ⚙️ CRUCIAL BINDING RULE: Ensures the Flutter engine is fully loaded before firing cloud channels
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 INITIALIZE FIREBASE WEB ENGINE: Loads your unique cloud connection keys live!
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyApZU-2qYHf1YHtS25JPBOidEZFc7P52mc",
      authDomain: "safeentry-3e3e8.firebaseapp.com",
      projectId: "safeentry-3e3e8",
      storageBucket: "safeentry-3e3e8.firebasestorage.app",
      messagingSenderId: "32973434929",
      appId: "1:32973434929:web:d221f590905015c12be510",
    ),
  );

  runApp(const SafeEntryAppContainer());
}

// 🏛️ MASTER IGNITION SWITCH CONTAINER
class SafeEntryAppContainer extends StatelessWidget {
  const SafeEntryAppContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeEntry Kenya',
      home: SafeEntryLoginRoom(), // 🚪 App secure entry landing gate
    );
  }
}

// 📜 YOUR ORIGINAL WEEK 1 ASSIGNMENT VIEW (Preserved perfectly for grading compliance)
class MyFirstMobileApp extends StatelessWidget {
  const MyFirstMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
              const Icon(Icons.shield, size: 80, color: Color(0xFF1A237E)),
              const SizedBox(height: 24),
              const Text(
                'Welcome to BIT 4107!',
                style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
              ),
              const SizedBox(height: 10),
              const Text(
                'First Mobile Application Practice',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  debugPrint("Week 1 Security Button Tapped Successfully!");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800), // Safety Orange
                  foregroundColor: Colors.white, 
                  minimumSize: const Size.fromHeight(50), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('INITIALIZE SYSTEM ENGINE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
