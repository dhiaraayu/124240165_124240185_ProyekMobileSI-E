import 'package:hive/hive.dart';

class Order {
  final String id;
  final String userId;
  final String packageId;
  final String packageName;
  final String attendance; // '3-Day' | 'Friday' | 'Saturday' | 'Sunday'
  final int quantity;
  final String attendeeName;
  final double totalPriceSGD;
  final String status; // 'paid' | 'cancelled'
  final DateTime createdAt;
  final int notifId;

  Order({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.packageName,
    required this.attendance,
    required this.quantity,
    required this.attendeeName,
    required this.totalPriceSGD,
    this.status = 'paid',
    required this.createdAt,
    required this.notifId,
  });

  Order copyWith({
    String? id,
    String? userId,
    String? packageId,
    String? packageName,
    String? attendance,
    int? quantity,
    String? attendeeName,
    double? totalPriceSGD,
    String? status,
    DateTime? createdAt,
    int? notifId,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      packageId: packageId ?? this.packageId,
      packageName: packageName ?? this.packageName,
      attendance: attendance ?? this.attendance,
      quantity: quantity ?? this.quantity,
      attendeeName: attendeeName ?? this.attendeeName,
      totalPriceSGD: totalPriceSGD ?? this.totalPriceSGD,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notifId: notifId ?? this.notifId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'packageId': packageId,
      'packageName': packageName,
      'attendance': attendance,
      'quantity': quantity,
      'attendeeName': attendeeName,
      'totalPriceSGD': totalPriceSGD,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'notifId': notifId,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      packageId: map['packageId'] ?? '',
      packageName: map['packageName'] ?? '',
      attendance: map['attendance'] ?? '3-Day',
      quantity: map['quantity'] ?? 1,
      attendeeName: map['attendeeName'] ?? '',
      totalPriceSGD: (map['totalPriceSGD'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'paid',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      notifId: map['notifId'] ?? 0,
    );
  }
}

class OrderAdapter extends TypeAdapter<Order> {
  @override
  final int typeId = 2;

  @override
  Order read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Order(
      id: fields[0] as String,
      userId: fields[1] as String,
      packageId: fields[2] as String,
      packageName: fields[3] as String,
      attendance: fields[4] as String,
      quantity: fields[5] as int,
      attendeeName: fields[6] as String,
      totalPriceSGD: (fields[7] as num).toDouble(),
      status: fields[8] as String,
      createdAt: DateTime.parse(fields[9] as String),
      notifId: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Order obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.packageId)
      ..writeByte(3)
      ..write(obj.packageName)
      ..writeByte(4)
      ..write(obj.attendance)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.attendeeName)
      ..writeByte(7)
      ..write(obj.totalPriceSGD)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.createdAt.toIso8601String())
      ..writeByte(10)
      ..write(obj.notifId);
  }
}
