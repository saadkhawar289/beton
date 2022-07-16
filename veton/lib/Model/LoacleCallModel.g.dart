// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'LoacleCallModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalStorageCallsAdapter extends TypeAdapter<LocalStorageCalls> {
  @override
  final int typeId = 0;

  @override
  LocalStorageCalls read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalStorageCalls()
      ..totalLength = fields[0] as int
      ..isVerified = fields[1] as bool
      ..clientId = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, LocalStorageCalls obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.totalLength)
      ..writeByte(1)
      ..write(obj.isVerified)
      ..writeByte(2)
      ..write(obj.clientId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalStorageCallsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
