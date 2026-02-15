import 'package:hive/hive.dart';
import '../models/sync_status.dart';

/// Hive adapter for SyncStatus enum
class SyncStatusAdapter extends TypeAdapter<SyncStatus> {
  @override
  final int typeId = 103;

  @override
  SyncStatus read(BinaryReader reader) {
    final index = reader.readByte();
    return SyncStatus.values[index];
  }

  @override
  void write(BinaryWriter writer, SyncStatus obj) {
    writer.writeByte(obj.index);
  }
}

/// Hive adapter for SyncOperation enum
class SyncOperationAdapter extends TypeAdapter<SyncOperation> {
  @override
  final int typeId = 101;

  @override
  SyncOperation read(BinaryReader reader) {
    final index = reader.readByte();
    return SyncOperation.values[index];
  }

  @override
  void write(BinaryWriter writer, SyncOperation obj) {
    writer.writeByte(obj.index);
  }
}
