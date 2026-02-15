import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/goals/data/models/goal_model.dart';

/// Hive TypeAdapter for GoalModel
class GoalModelAdapter extends TypeAdapter<GoalModel> {
  @override
  final int typeId = 5;

  @override
  GoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return GoalModel(
      id: fields[0] as String,
      name: fields[1] as String,
      targetAmount: fields[2] as int,
      currentAmount: fields[3] as int,
      progress: fields[4] as double,
      targetDate: fields[5] as DateTime?,
      icon: fields[6] as String?,
      color: fields[7] as String?,
      status: GoalStatus.values[fields[8] as int],
      monthlyRequired: fields[9] as int?,
      linkedAccountId: fields[10] as String?,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GoalModel obj) {
    writer
      ..writeByte(13) // Number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.targetAmount)
      ..writeByte(3)
      ..write(obj.currentAmount)
      ..writeByte(4)
      ..write(obj.progress)
      ..writeByte(5)
      ..write(obj.targetDate)
      ..writeByte(6)
      ..write(obj.icon)
      ..writeByte(7)
      ..write(obj.color)
      ..writeByte(8)
      ..write(obj.status.index)
      ..writeByte(9)
      ..write(obj.monthlyRequired)
      ..writeByte(10)
      ..write(obj.linkedAccountId)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalModelAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

/// Hive TypeAdapter for GoalStatus enum
class GoalStatusAdapter extends TypeAdapter<GoalStatus> {
  @override
  final int typeId = 14;

  @override
  GoalStatus read(BinaryReader reader) {
    return GoalStatus.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, GoalStatus obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalStatusAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
