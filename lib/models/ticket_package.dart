import 'package:hive/hive.dart';

class TicketPackage {
  final String id;
  final String category; // 'grandstand' | 'walkabout' | 'hospitality'
  final String name;
  final String zoneAccess;
  final String gates;
  final String location;
  final double price3Day;
  final double? priceFri;
  final double? priceSat;
  final double? priceSun;
  final List<String> overview;
  final String description;
  final String imageAsset;
  final String status; // 'available' | 'soldOut' | 'unavailable'
  final bool featured;

  TicketPackage({
    required this.id,
    required this.category,
    required this.name,
    required this.zoneAccess,
    required this.gates,
    required this.location,
    required this.price3Day,
    this.priceFri,
    this.priceSat,
    this.priceSun,
    required this.overview,
    required this.description,
    required this.imageAsset,
    this.status = 'available',
    this.featured = false,
  });

  bool get isAvailable => status.toLowerCase() == 'available';

  String get effectiveImageAsset {
    if (imageAsset.isNotEmpty) return imageAsset;
    return 'assets/images/$id.jpg';
  }

  double? getPriceForDay(String day) {
    switch (day) {
      case '3-Day':
        return price3Day;
      case 'Friday':
        return priceFri;
      case 'Saturday':
        return priceSat;
      case 'Sunday':
        return priceSun;
      default:
        return price3Day;
    }
  }

  bool isDayAvailable(String day) {
    if (!isAvailable) return false;
    final price = getPriceForDay(day);
    return price != null && price > 0;
  }

  List<String> get availableDays {
    final list = <String>[];
    if (price3Day > 0) list.add('3-Day');
    if (priceFri != null && priceFri! > 0) list.add('Friday');
    if (priceSat != null && priceSat! > 0) list.add('Saturday');
    if (priceSun != null && priceSun! > 0) list.add('Sunday');
    return list;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'zoneAccess': zoneAccess,
      'gates': gates,
      'location': location,
      'price3Day': price3Day,
      'priceFri': priceFri,
      'priceSat': priceSat,
      'priceSun': priceSun,
      'overview': overview,
      'description': description,
      'imageAsset': imageAsset,
      'status': status,
      'featured': featured,
    };
  }

  factory TicketPackage.fromMap(Map<String, dynamic> map) {
    return TicketPackage(
      id: map['id'] ?? '',
      category: map['category'] ?? 'grandstand',
      name: map['name'] ?? '',
      zoneAccess: map['zoneAccess'] ?? '-',
      gates: map['gates'] ?? '-',
      location: map['location'] ?? '-',
      price3Day: (map['price3Day'] as num?)?.toDouble() ?? 0.0,
      priceFri: (map['priceFri'] as num?)?.toDouble(),
      priceSat: (map['priceSat'] as num?)?.toDouble(),
      priceSun: (map['priceSun'] as num?)?.toDouble(),
      overview: (map['overview'] as List?)?.map((e) => e.toString()).toList() ?? [],
      description: map['description'] ?? '',
      imageAsset: map['imageAsset'] ?? '',
      status: map['status'] ?? 'available',
      featured: map['featured'] ?? false,
    );
  }
}

class TicketPackageAdapter extends TypeAdapter<TicketPackage> {
  @override
  final int typeId = 1;

  @override
  TicketPackage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TicketPackage(
      id: fields[0] as String,
      category: fields[1] as String,
      name: fields[2] as String,
      zoneAccess: fields[3] as String,
      gates: fields[4] as String,
      location: fields[5] as String,
      price3Day: (fields[6] as num).toDouble(),
      priceFri: (fields[7] as num?)?.toDouble(),
      priceSat: (fields[8] as num?)?.toDouble(),
      priceSun: (fields[9] as num?)?.toDouble(),
      overview: (fields[10] as List).cast<String>(),
      description: fields[11] as String,
      imageAsset: fields[12] as String,
      status: fields[13] as String? ?? 'available',
      featured: fields[14] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, TicketPackage obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.zoneAccess)
      ..writeByte(4)
      ..write(obj.gates)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.price3Day)
      ..writeByte(7)
      ..write(obj.priceFri)
      ..writeByte(8)
      ..write(obj.priceSat)
      ..writeByte(9)
      ..write(obj.priceSun)
      ..writeByte(10)
      ..write(obj.overview)
      ..writeByte(11)
      ..write(obj.description)
      ..writeByte(12)
      ..write(obj.imageAsset)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.featured);
  }
}
