import 'package:hive/hive.dart';
import '../../../features/budgets/data/models/budget_model.dart';
import '../../../core/constants/app_constants.dart';

/// Hive TypeAdapter for BudgetModel
class BudgetModelAdapter extends TypeAdapter<BudgetModel> {
  @override
  final int typeId = 3;

  @override
  BudgetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return BudgetModel(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: fields[2] as int,
      spent: fields[3] as int,
      remaining: fields[4] as int,
      percentage: fields[5] as double,
      categoryId: fields[6] as String?,
      period: BudgetPeriod.values[fields[7] as int],
      startDate: fields[8] as DateTime,
      endDate: fields[9] as DateTime,
      alertThreshold: fields[10] as int? ?? 80,
      isActive: fields[11] as bool? ?? true,
      rollover: fields[12] as bool? ?? false,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
      // Note: category is transient and not stored
    );
  }

  @override
  void write(BinaryWriter writer, BudgetModel obj) {
    writer
      ..writeByte(15) // Number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.spent)
      ..writeByte(4)
      ..write(obj.remaining)
      ..writeByte(5)
      ..write(obj.percentage)
      ..writeByte(6)
      ..write(obj.categoryId)
      ..writeByte(7)
      ..write(obj.period.index)
      ..writeByte(8)
      ..write(obj.startDate)
      ..writeByte(9)
      ..write(obj.endDate)
      ..writeByte(10)
      ..write(obj.alertThreshold)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.rollover)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Hive TypeAdapter for BudgetPeriod enum
class BudgetPeriodAdapter extends TypeAdapter<BudgetPeriod> {
  @override
  final int typeId = 12;

  @override
  BudgetPeriod read(BinaryReader reader) {
    return BudgetPeriod.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, BudgetPeriod obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetPeriodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
