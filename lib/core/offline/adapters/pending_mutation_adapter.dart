import 'package:hive/hive.dart';
import '../models/pending_mutation.dart';
import '../models/sync_status.dart';

/// Hive adapter for PendingMutation
class PendingMutationAdapter extends TypeAdapter<PendingMutation> {
  @override
  final int typeId = 100;

  @override
  PendingMutation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingMutation(
      id: fields[0] as String,
      entityType: fields[1] as String,
      entityId: fields[2] as String,
      operation: fields[3] as SyncOperation,
      data: Map<String, dynamic>.from(fields[4] as Map),
      createdAt: fields[5] as DateTime,
      retryCount: fields[6] as int,
      errorMessage: fields[7] as String?,
      lastAttemptAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PendingMutation obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.entityType)
      ..writeByte(2)
      ..write(obj.entityId)
      ..writeByte(3)
      ..write(obj.operation)
      ..writeByte(4)
      ..write(obj.data)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.retryCount)
      ..writeByte(7)
      ..write(obj.errorMessage)
      ..writeByte(8)
      ..write(obj.lastAttemptAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingMutationAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
