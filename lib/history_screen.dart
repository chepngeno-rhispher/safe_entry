// lib/history_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'visitor_model.dart';
import 'database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _db = DatabaseService();
  List<Visitor> _allVisitors = [];
  List<Visitor> _filteredVisitors = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterType = 'All'; // All, Today, This Week, This Month

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      await _db.init();
      _allVisitors = await _db.getAllVisitors();
      _applyFilters();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error loading history: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<Visitor> filtered = List.from(_allVisitors);

    // Apply date filter
    final now = DateTime.now();
    DateTime startDate;

    switch (_filterType) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        filtered = filtered.where((v) => v.checkInTime.isAfter(startDate)).toList();
        break;
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        filtered = filtered.where((v) => v.checkInTime.isAfter(startDate)).toList();
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        filtered = filtered.where((v) => v.checkInTime.isAfter(startDate)).toList();
        break;
      default:
        // 'All' - no filter
        break;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((v) {
        return v.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            v.hostUnit.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Sort by check-in time (newest first)
    filtered.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

    setState(() {
      _filteredVisitors = filtered;
    });
  }

  Future<void> _exportHistoryToCSV() async {
    if (_filteredVisitors.isEmpty) {
      Fluttertoast.showToast(
        msg: 'No data to export!',
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return;
    }

    try {
      // Build CSV content
      String csvContent = 'ID,Full Name,Host Unit,Check-In Time,Check-Out Time,Status\n';

      for (var visitor in _filteredVisitors) {
        String status = visitor.isActive ? 'Active' : 'Checked Out';
        String checkOut = visitor.checkOutTime != null
            ? visitor.checkOutTime!.toIso8601String()
            : 'Still Active';

        csvContent += '${visitor.id},'
            '"${visitor.fullName}",'
            '"${visitor.hostUnit}",'
            '${visitor.checkInTime.toIso8601String()},'
            '$checkOut,'
            '$status\n';
      }

      // Save file
      String fileName = 'visitor_history_${DateTime.now().toIso8601String().replaceAll(':', '-')}.csv';

      Directory? downloadsDir;
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        downloadsDir = await getDownloadsDirectory();
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir != null) {
        String filePath = '${downloadsDir.path}/$fileName';
        File file = File(filePath);
        await file.writeAsString(csvContent, encoding: utf8);

        Fluttertoast.showToast(
          msg: '✅ History exported: $fileName',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );

        _showFileLocationDialog(filePath);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: '❌ Export failed: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
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
            const Text('Your history report has been saved at:'),
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

  // Stats calculations
  int get _totalVisitors => _filteredVisitors.length;
  int get _activeVisitors => _filteredVisitors.where((v) => v.isActive).length;
  int get _checkedOutVisitors => _filteredVisitors.where((v) => !v.isActive).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor History'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportHistoryToCSV,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.indigo.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Total', _totalVisitors.toString(), Colors.blue),
                _buildStatItem('Active', _activeVisitors.toString(), Colors.green),
                _buildStatItem('Checked Out', _checkedOutVisitors.toString(), Colors.grey),
              ],
            ),
          ),

          // Filter and Search
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      _buildFilterChip('Today'),
                      _buildFilterChip('This Week'),
                      _buildFilterChip('This Month'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Search bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilters();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '🔍 Search by name or unit...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

          // Visitor List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredVisitors.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _filteredVisitors.length,
                        itemBuilder: (context, index) {
                          final visitor = _filteredVisitors[index];
                          return _buildVisitorCard(visitor);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _filterType == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterType = label;
            _applyFilters();
          });
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.indigo.shade100,
        checkmarkColor: Colors.indigo,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Visitor History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Visitors will appear here after they check in',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorCard(Visitor visitor) {
    final bool isActive = visitor.isActive;
    final String status = isActive ? '🟢 Active' : '🔴 Checked Out';
    final Color statusColor = isActive ? Colors.green : Colors.red;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isActive ? Colors.green.shade100 : Colors.grey.shade300,
              child: Text(
                visitor.fullName.isNotEmpty ? visitor.fullName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: isActive ? Colors.green.shade800 : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visitor.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.apartment, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        visitor.hostUnit,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(visitor.checkInTime),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (visitor.checkOutTime != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Checked out: ${_formatTime(visitor.checkOutTime!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}