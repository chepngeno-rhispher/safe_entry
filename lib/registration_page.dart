// lib/dashboard.dart

import 'package:flutter/material.dart';

class VisitorRegistryRoom extends StatefulWidget {
  const VisitorRegistryRoom({super.key});

  @override
  State<VisitorRegistryRoom> createState() => _VisitorRegistryRoomState();
}

class _VisitorRegistryRoomState extends State<VisitorRegistryRoom> {
  final TextEditingController _visitorNameController = TextEditingController();
  final TextEditingController _destinationUnitController = TextEditingController();
  
  String _savedLocalRecordText = "No local visitor entries registered yet.";

  void _executeLocalSave() {
    String name = _visitorNameController.text.trim();
    String unit = _destinationUnitController.text.trim();

    if (name.isEmpty || unit.isEmpty) {
      setState(() {
        _savedLocalRecordText = "❌ Save Failed! Fields cannot be blank.";
      });
      return;
    }

    // 💾 LOCAL STORAGE SIMULATION: Commits entries into application state cache memory
    setState(() {
      _savedLocalRecordText = "💾 Saved Locally!\nVisitor: $name\nDestination: $unit";
    });

    _visitorNameController.clear();
    _destinationUnitController.clear();
  }

  @override
  void dispose() {
    _visitorNameController.dispose();
    _destinationUnitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('SafeEntry Registry Form', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A237E),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "NEW ENTRY REGISTRATION",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _visitorNameController,
              decoration: const InputDecoration(
                labelText: "Full Visitor Name",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _destinationUnitController,
              decoration: const InputDecoration(
                labelText: "Host Unit / Apartment Number",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _executeLocalSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("SAVE RECORD LOCALLY", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _savedLocalRecordText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
