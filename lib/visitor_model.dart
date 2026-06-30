
// lib/visitor_model.dart

import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Visitor {
  @HiveField(0)
  int? id;
  
  @HiveField(1)
  String fullName;
  
  @HiveField(2)
  String hostUnit;
  
  @HiveField(3)
  DateTime checkInTime;
  
  @HiveField(4)
  DateTime? checkOutTime;
  
  @HiveField(5)
  bool isActive;
  @HiveField(6)  // ← NEW FIELD
  String? photoPath;  // ← 

  Visitor({
    this.id,
    required this.fullName,
    required this.hostUnit,
    required this.checkInTime,
    this.checkOutTime,
    this.isActive = true,
     this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'hostUnit': hostUnit,
      'checkInTime': checkInTime.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'photoPath': photoPath,

    };
  }

  factory Visitor.fromMap(Map<String, dynamic> map) {
    return Visitor(
      id: map['id'],
      fullName: map['fullName'],
      hostUnit: map['hostUnit'],
      checkInTime: DateTime.parse(map['checkInTime']),
      checkOutTime: map['checkOutTime'] != null 
          ? DateTime.parse(map['checkOutTime']) 
          : null,
      isActive: map['isActive'] == 1,
      photoPath: map['photoPath'],  // ← NEW FIELD
    );
  }
}