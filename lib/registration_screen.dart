// lib/registration_screen.dart

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'visitor_model.dart';
import 'database_service.dart';
import 'verification_screen.dart';
import 'live_logs_screen.dart';
import 'settings_screen.dart';
import 'notification_service.dart';
import 'history_screen.dart';
import 'weather_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // ===== WEATHER VARIABLES =====
  String _weather = 'Loading...';
  String _temperature = '--';
  String _weatherIcon = '☁️';
  final String _city = 'Nairobi';

  // ===== CONTROLLERS =====
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hostController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // ===== PHOTO VARIABLES =====
  File? _visitorPhoto;
  final ImagePicker _picker = ImagePicker();

  final DatabaseService _db = DatabaseService();

  // ===== INIT STATE =====
  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  // ===== FETCH WEATHER =====
  Future<void> _fetchWeather() async {
    try {
      final service = WeatherService();
      final data = await service.getWeather(_city);

      if (data.containsKey('error')) {
        setState(() {
          _weather = 'Weather unavailable';
        });
        return;
      }

      setState(() {
        _weather = data['weather'][0]['description'];
        _temperature = data['main']['temp'].round().toString();
        _weatherIcon = _getWeatherIcon(data['weather'][0]['icon']);
      });
    } catch (e) {
      setState(() {
        _weather = 'Weather unavailable';
      });
    }
  }

  // ===== GET WEATHER ICON =====
  String _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
        return '☀️';
      case '01n':
        return '🌙';
      case '02d':
        return '⛅';
      case '02n':
        return '☁️';
      case '03d':
      case '03n':
        return '☁️';
      case '04d':
      case '04n':
        return '☁️';
      case '09d':
      case '09n':
        return '🌧️';
      case '10d':
      case '10n':
        return '🌦️';
      case '11d':
      case '11n':
        return '⛈️';
      case '13d':
      case '13n':
        return '❄️';
      case '50d':
      case '50n':
        return '🌫️';
      default:
        return '☁️';
    }
  }

  // ===== TAKE PHOTO =====
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      if (photo != null) {
        setState(() {
          _visitorPhoto = File(photo.path);
        });
        Fluttertoast.showToast(
          msg: '📸 Photo captured successfully!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to take photo: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // ===== REMOVE PHOTO =====
  void _removePhoto() {
    setState(() {
      _visitorPhoto = null;
    });
  }

  // ===== SAVE VISITOR =====
  Future<void> _saveVisitor() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await _db.init();
      Visitor newVisitor = Visitor(
        fullName: _nameController.text.trim(),
        hostUnit: _hostController.text.trim(),
        checkInTime: DateTime.now(),
        isActive: true,
        photoPath: _visitorPhoto?.path,
      );
      int id = await _db.insertVisitor(newVisitor);
      newVisitor.id = id;
      await NotificationService().showHostNotification(
        visitorName: newVisitor.fullName,
        hostUnit: newVisitor.hostUnit,
      );
      Fluttertoast.showToast(
        msg: '✅ ${newVisitor.fullName} checked in successfully!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(visitor: newVisitor),
        ),
      );
      _nameController.clear();
      _hostController.clear();
      _removePhoto();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ===== BUILD =====
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final maxWidth = isMobile ? double.infinity : 500.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SafeEntry Registry',
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LiveLogsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 22),
            onSelected: (value) {
              if (value == 'history') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history, size: 20),
                    SizedBox(width: 10),
                    Text('Visitor History'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEW ENTRY REGISTRATION',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please fill in the visitor details below',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),

                // ===== WEATHER WIDGET =====
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Text(_weatherIcon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🌤️ Weather',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '$_temperature°C, $_weather',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _city,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== PHOTO SECTION =====
                Center(
                  child: Column(
                    children: [
                      _visitorPhoto == null
                          ? GestureDetector(
                              onTap: _takePhoto,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      color: Colors.grey.shade400, width: 2),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt,
                                        size: 30, color: Colors.grey),
                                    SizedBox(height: 4),
                                    Text('Tap',
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            )
                          : Stack(
                              alignment: Alignment.topRight,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: FileImage(_visitorPhoto!),
                                  backgroundColor: Colors.grey.shade200,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red, size: 18),
                                  onPressed: _removePhoto,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(2),
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _takePhoto,
                        child: Text(
                          _visitorPhoto == null ? '📸 Add Photo' : '📷 Retake',
                          style: TextStyle(
                              color: Colors.indigo.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ===== FORM =====
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Visitor Name',
                          hintText: 'e.g., John Doe',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter visitor name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _hostController,
                        decoration: const InputDecoration(
                          labelText: 'Host Unit / Apartment Number',
                          hintText: 'e.g., Unit A-12',
                          prefixIcon: Icon(Icons.apartment),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter host unit/apartment';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveVisitor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text(
                                  'SAVE RECORD LOCALLY',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ===== INFO CARD =====
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'All entries are saved locally',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('SECURE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
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