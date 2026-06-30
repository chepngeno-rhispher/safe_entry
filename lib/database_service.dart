// lib/database_service.dart

import 'package:hive/hive.dart';
import 'visitor_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late Box _visitorBox;

  Future<void> init() async {
    // Register the Visitor adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(VisitorAdapter());
    }
    _visitorBox = await Hive.openBox('visitors');
  }

  Future<int> insertVisitor(Visitor visitor) async {
    await init();
    int id = _visitorBox.length + 1;
    visitor.id = id;
    await _visitorBox.put(id, visitor);
    return id;
  }

  Future<List<Visitor>> getActiveVisitors() async {
    await init();
    return _visitorBox.values
        .where((visitor) => visitor.isActive)
        .cast<Visitor>()
        .toList()
        .reversed
        .toList();
  }

  Future<List<Visitor>> getAllVisitors() async {
    await init();
    return _visitorBox.values.cast<Visitor>().toList().reversed.toList();
  }

  Future<void> checkOutVisitor(int id) async {
    await init();
    Visitor? visitor = _visitorBox.get(id);
    if (visitor != null) {
      visitor.isActive = false;
      visitor.checkOutTime = DateTime.now();
      await _visitorBox.put(id, visitor);
    }
  }

  Future<void> deleteVisitor(int id) async {
    await init();
    await _visitorBox.delete(id);
  }

  Future<void> clearAllData() async {
    await init();
    await _visitorBox.clear();
  }
}

// Hive Adapter for Visitor model
class VisitorAdapter extends TypeAdapter<Visitor> {
  @override
  final int typeId = 0;

  // lib/database_service.dart

// In the VisitorAdapter class, update read and write methods:

  @override
  Visitor read(BinaryReader reader) {
    return Visitor(
      id: reader.readInt(),
      fullName: reader.readString(),
      hostUnit: reader.readString(),
      checkInTime: DateTime.parse(reader.readString()),
      checkOutTime:
          reader.readBool() ? DateTime.parse(reader.readString()) : null,
      isActive: reader.readBool(),
      photoPath: reader.readBool() ? reader.readString() : null, // ← NEW
    );
  }

  @override
  void write(BinaryWriter writer, Visitor obj) {
    writer.writeInt(obj.id!);
    writer.writeString(obj.fullName);
    writer.writeString(obj.hostUnit);
    writer.writeString(obj.checkInTime.toIso8601String());
    if (obj.checkOutTime != null) {
      writer.writeBool(true);
      writer.writeString(obj.checkOutTime!.toIso8601String());
    } else {
      writer.writeBool(false);
    }
    writer.writeBool(obj.isActive);
    // Write photo
    if (obj.photoPath != null) {
      writer.writeBool(true);
      writer.writeString(obj.photoPath!);
    } else {
      writer.writeBool(false);
    }
  }
}
