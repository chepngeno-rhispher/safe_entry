// lib/settings_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'visitor_model.dart';
import 'database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  // ===== EXPORT DATA =====
  Future<void> _exportData() async {
    setState(() => _isLoading = true);

    try {
      // 1. Get all visitors
      await _db.init();
      List<Visitor> allVisitors = await _db.getAllVisitors();

      if (allVisitors.isEmpty) {
        Fluttertoast.showToast(
          msg: 'No data to export!',
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
        setState(() => _isLoading = false);
        return;
      }

      // 2. Convert to JSON
      List<Map<String, dynamic>> jsonData = allVisitors.map((visitor) {
        return {
          'id': visitor.id,
          'fullName': visitor.fullName,
          'hostUnit': visitor.hostUnit,
          'checkInTime': visitor.checkInTime.toIso8601String(),
          'checkOutTime': visitor.checkOutTime?.toIso8601String(),
          'isActive': visitor.isActive,
        };
      }).toList();

      String jsonString = jsonEncode(jsonData);

      // 3. Get download directory
      String fileName = 'safe_entry_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
      
      // Save to downloads folder (or documents)
      Directory? downloadsDir;
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // Desktop: Save to Downloads
        downloadsDir = await getDownloadsDirectory();
      } else {
        // Mobile: Save to Documents
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir != null) {
        String filePath = '${downloadsDir.path}/$fileName';
        File file = File(filePath);
        await file.writeAsString(jsonString, encoding: utf8);

        Fluttertoast.showToast(
          msg: '✅ Data exported successfully!\nSaved to: $fileName',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );

        // Show file location
        _showFileLocationDialog(filePath);
      } else {
        // Fallback: Ask user where to save using file picker
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Backup File',
          fileName: fileName,
        );

        if (outputFile != null) {
          File file = File(outputFile);
          await file.writeAsString(jsonString, encoding: utf8);
          Fluttertoast.showToast(
            msg: '✅ Data exported successfully!',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: '❌ Export failed: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ===== IMPORT DATA =====
  Future<void> _importData() async {
    setState(() => _isLoading = true);

    try {
      // 1. Request storage permission (Android only)
      if (Platform.isAndroid) {
        PermissionStatus status = await Permission.storage.request();
        if (!status.isGranted) {
          Fluttertoast.showToast(
            msg: 'Storage permission is required to import data.',
            backgroundColor: Colors.orange,
            textColor: Colors.white,
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      // 2. Pick JSON file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Backup File to Import',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) {
        setState(() => _isLoading = false);
        return; // User cancelled
      }

      // 3. Read file
      String filePath = result.files.single.path!;
      File file = File(filePath);
      String jsonString = await file.readAsString(encoding: utf8);

      // 4. Parse JSON
      List<dynamic> jsonList = jsonDecode(jsonString);
      List<Visitor> importedVisitors = [];

      for (var json in jsonList) {
        Visitor visitor = Visitor(
          id: json['id'],
          fullName: json['fullName'],
          hostUnit: json['hostUnit'],
          checkInTime: DateTime.parse(json['checkInTime']),
          checkOutTime: json['checkOutTime'] != null
              ? DateTime.parse(json['checkOutTime'])
              : null,
          isActive: json['isActive'] ?? true,
        );
        importedVisitors.add(visitor);
      }

      if (importedVisitors.isEmpty) {
        Fluttertoast.showToast(
          msg: 'No valid data found in this file.',
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
        setState(() => _isLoading = false);
        return;
      }

      // 5. Confirm overwrite
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('⚠️ Confirm Import'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This will replace all existing data with the imported data.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Visitors to import: ${importedVisitors.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Import',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirm != true) {
        setState(() => _isLoading = false);
        return;
      }

      // 6. Clear existing data and import new
      await _db.init();
      await _db.clearAllData();

      for (Visitor visitor in importedVisitors) {
        await _db.insertVisitor(visitor);
      }

      Fluttertoast.showToast(
        msg: '✅ Successfully imported ${importedVisitors.length} visitors!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: '❌ Import failed: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ===== CLEAR ALL DATA =====
 Future<void> _clearAllData() async {
  // 1️⃣ Check if widget is mounted
  if (!mounted) return;
  
  // 2️⃣ Show confirmation dialog
  bool? confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('⚠️ Clear All Data'),
      content: const Text(
        'Are you sure you want to delete ALL visitor data? This cannot be undone.',
        style: TextStyle(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text(
            'Clear All',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );

  // 3️⃣ If user cancelled, exit
  if (confirm != true) {
    return;
  }

  // 4️⃣ Clear the data
  setState(() => _isLoading = true);
  try {
    await _db.init();
    await _db.clearAllData();
    Fluttertoast.showToast(
      msg: 'All data cleared successfully.',
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  } catch (e) {
    Fluttertoast.showToast(
      msg: 'Failed to clear data: $e',
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  } finally {
    // 5️⃣ Only update UI if still mounted
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  void _showFileLocationDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ File Saved!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your backup file has been saved at:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                filePath,
                style: const TextStyle(fontSize: 12),
                softWrap: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== BACKUP SECTION =====
            const Text(
              'BACKUP & RESTORE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Export all visitor data to a file, or import from a backup file.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Export Button
            _buildSettingsCard(
              icon: Icons.download,
              title: 'Export Data',
              subtitle: 'Save all visitor data as a JSON file',
              color: Colors.blue,
              onTap: _exportData,
            ),

            const SizedBox(height: 12),

            // Import Button
            _buildSettingsCard(
              icon: Icons.upload,
              title: 'Import Data',
              subtitle: 'Restore data from a backup JSON file',
              color: Colors.green,
              onTap: _importData,
            ),

            const SizedBox(height: 32),

            // ===== DANGER SECTION =====
            const Divider(),
            const SizedBox(height: 16),

            const Text(
              '⚠️ DANGER ZONE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'These actions cannot be undone. Proceed with caution.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Clear All Data Button
            _buildSettingsCard(
              icon: Icons.delete_forever,
              title: 'Clear All Data',
              subtitle: 'Permanently delete ALL visitor records',
              color: Colors.red,
              onTap: _clearAllData,
            ),

            const SizedBox(height: 32),

            // ===== INFO SECTION =====
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡 Tips',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Export data regularly to keep backups safe.\n'
                      '• Store backup files in multiple locations (cloud, email, USB).\n'
                      '• Import will REPLACE all current data with the backup.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}