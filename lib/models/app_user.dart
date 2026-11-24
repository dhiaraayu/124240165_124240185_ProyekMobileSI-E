import 'package:hive/hive.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final String salt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.salt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'salt': salt,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      passwordHash: map['passwordHash'] ?? '',
      salt: map['salt'] ?? '',
    );
  }
}

class AppUserAdapter extends TypeAdapter<AppUser> {
  @override
  final int typeId = 0;

  @override
  AppUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUser(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      passwordHash: fields[3] as String,
      salt: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppUser obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.passwordHash)
      ..writeByte(4)
      ..write(obj.salt);
  }
}
