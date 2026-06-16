// lib/registration_page.dart

import 'package:flutter/material.dart';
import 'database.dart'; // Links straight to your local database helper file
import 'package:cloud_firestore/cloud_firestore.dart'; // Links your app to your live Firebase Cloud workspace

// 💾 GLOBAL RUNTIME CACHE: Placed outside the class so the browser can NEVER clear it on rebuilds!
final List<Map<String, String>> _globalWebLogStorage = [];

class VisitorRegistryRoom extends StatefulWidget {
  const VisitorRegistryRoom({super.key});

  @override
  State<VisitorRegistryRoom> createState() => _VisitorRegistryRoomState();
}

class _VisitorRegistryRoomState extends State<VisitorRegistryRoom> {
  // Interactive controllers to harvest string properties from text boxes
  final TextEditingController _visitorNameController = TextEditingController();
  final TextEditingController _destinationUnitController = TextEditingController();

  // 🧠 THE COUPLING DATA BACKEND LOGIC CONTAINER
  void _executeLocalAndCloudSave() async {
    String name = _visitorNameController.text.trim();
    String unit = _destinationUnitController.text.trim();

    // Verification check constraint rules
    if (name.isEmpty || unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Save Failed! Input fields cannot be blank.")),
      );
      return;
    }

    // Capture standard timestamp for data tracking
    String currentTimestamp = DateTime.now().toIso8601String();

    // Prepare row mapping layout package for SQLite tracking
    Map<String, dynamic> visitorRowData = {
      'fullName': name,
      'hostUnit': unit,
      'timestamp': currentTimestamp,
    };

    // 🌐 1. FIREBASE CLOUD NETWORK STREAM INJECTION TRACK (Outgoing Network Packet)
    try {
      await FirebaseFirestore.instance.collection('visitors').add({
        'name': name,
        'unit': unit,
        'timestamp': currentTimestamp,
        'devMode': 'Network Integration'
      });
      debugPrint("🚀 Outgoing Network Packet Successful: Mirrored to Cloud!");
    } catch (cloudNetworkError) {
      debugPrint("☁️ Cloud network queue buffered offline: $cloudNetworkError");
    }

    // 💾 2. LOCAL ENGINE WRITING STREAMS (Your SQLite and Fallback Memory Track)
    try {
      int databaseRowId = await LocalDatabaseManager.instance.insertVisitor(visitorRowData);
      setState(() {
        _globalWebLogStorage.insert(0, {
          'id': databaseRowId.toString(),
          'name': name,
          'unit': unit,
        });
      });
    } catch (browserError) {
      // FIXED BROWSER FALLBACK: Appends directly to our global array that can't be cleared!
      setState(() {
        _globalWebLogStorage.insert(0, {
          'id': (_globalWebLogStorage.length + 1).toString(),
          'name': name,
          'unit': unit,
        });
      });
      debugPrint("Bypassed browser hard drive database constraint: $browserError");
    }

    // Clear input terminals for the next vehicle arrival trace
    _visitorNameController.clear();
    _destinationUnitController.clear();
  }

  @override
  void dispose() {
    _visitorNameController.dispose();
    _destinationUnitController.dispose();
    super.dispose();
  }

  // 🎨 VISUAL INTERFACE RENDERER TREE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('SafeEntry Registry Form', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A237E), // Deep Security Navy Blue
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

            // Material Text Input Box 1
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

            // Material Text Input Box 2
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

            // Primary Safety Orange Action Trigger Button
            ElevatedButton(
              onPressed: _executeLocalAndCloudSave, 
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800), // Safety Orange Accent
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("SAVE RECORD SECURELY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 32),

            const Text(
              "LIVE VISITOR LEDGER ENGINE LOGS",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // 📊 📡 DYNAMIC NETWORK INCOMING DATA PIPELINE BOX
            Container(
              height: 260, 
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(8),
              ),
              // 📶 STREAMBUILDER: Actively listens to your live Firebase Cloud network stream!
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('visitors')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  // Network Loading State Indicator
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)));
                  }

                  // Network Connection Error Safe Gate
                  if (snapshot.hasError) {
                    return const Center(child: Text("⚠️ Network sync error occurred.", style: TextStyle(color: Colors.red)));
                  }

                  // Network Success Empty State Gate
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No cloud network entries registered yet.", style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic)));
                  }

                  // Reading documents from the live server stream snapshot payload array
                  final cloudDocs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: cloudDocs.length,
                    itemBuilder: (context, index) {
                      final visitorData = cloudDocs[index].data() as Map<String, dynamic>;
                      
                      // Handling potential missing keys gracefully
                      final String nameString = visitorData['name'] ?? 'Unknown';
                      final String unitString = visitorData['unit'] ?? 'N/A';

                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1A237E),
                            // Increments list sequence based on total network collection document length
                            child: Text((cloudDocs.length - index).toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(nameString, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                          subtitle: Text("Destination Unit: $unitString", style: const TextStyle(color: Colors.black54)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
