// lib/live_logs_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'visitor_model.dart';
import 'database_service.dart';
import 'registration_screen.dart';
import 'notification_service.dart';

class LiveLogsScreen extends StatefulWidget {
  const LiveLogsScreen({super.key});

  @override
  State<LiveLogsScreen> createState() => _LiveLogsScreenState();
}

class _LiveLogsScreenState extends State<LiveLogsScreen> {
  final DatabaseService _db = DatabaseService();
  List<Visitor> _activeVisitors = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadActiveVisitors();
  }

  Future<void> _loadActiveVisitors() async {
    setState(() => _isLoading = true);
    try {
      await _db.init();
      final visitors = await _db.getActiveVisitors();
      setState(() {
        _activeVisitors = visitors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: 'Error loading visitors: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  List<Visitor> _filteredVisitors() {
    if (_searchQuery.isEmpty) {
      return _activeVisitors;
    }
    return _activeVisitors.where((visitor) {
      return visitor.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             visitor.hostUnit.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _checkOutVisitor(Visitor visitor) async {
    setState(() => _isLoading = true);
    try {
      await _db.checkOutVisitor(visitor.id!);
      await NotificationService().showCheckoutNotification(
        visitorName: visitor.fullName,
      );
      Fluttertoast.showToast(
        msg: '✅ ${visitor.fullName} has checked out',
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      await _loadActiveVisitors();
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: 'Error: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredVisitors();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Compound Logs'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActiveVisitors,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegistrationScreen(),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: '🔍 Search by name or unit...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activeVisitors.isEmpty && _searchQuery.isEmpty
              ? _buildEmptyState()
              : filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'No visitors match your search',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    )
                  : _buildVisitorList(filtered),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Visitors',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All visitors have checked out',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegistrationScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Check in a visitor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorList(List<Visitor> visitors) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: visitors.length,
      itemBuilder: (context, index) {
        final visitor = visitors[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.green.shade300,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF1A237E),
                  radius: 22,
                  backgroundImage: visitor.photoPath != null
                      ? MemoryImage(base64Decode(visitor.photoPath!)) as ImageProvider
                      : null,
                  child: visitor.photoPath == null
                      ? Text(
                          visitor.fullName.isNotEmpty
                              ? visitor.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitor.fullName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.apartment,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            visitor.hostUnit,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(visitor.checkInTime),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _checkOutVisitor(visitor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  icon: const Icon(
                    Icons.exit_to_app,
                    size: 14,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Check Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}