import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/transactions/data/models/transaction_model.dart';

/// Hive TypeAdapter for TransactionModel
class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 1;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return TransactionModel(
      id: fields[0] as String,
      type: TransactionType.values[fields[1] as int],
      amount: fields[2] as int,
      description: fields[3] as String?,
      notes: fields[4] as String?,
      accountId: fields[5] as String,
      categoryId: fields[6] as String?,
      toAccountId: fields[7] as String?,
      date: fields[8] as DateTime,
      tags: (fields[9] as List?)?.cast<String>() ?? [],
      payee: fields[10] as String?,
      receiptUrl: fields[11] as String?,
      isRecurring: fields[12] as bool? ?? false,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
      // Note: account, category, toAccount are transient and not stored
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(15) // Number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type.index)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.accountId)
      ..writeByte(6)
      ..write(obj.categoryId)
      ..writeByte(7)
      ..write(obj.toAccountId)
      ..writeByte(8)
      ..write(obj.date)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.payee)
      ..writeByte(11)
      ..write(obj.receiptUrl)
      ..writeByte(12)
      ..write(obj.isRecurring)
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
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Hive TypeAdapter for TransactionType enum
class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 10;

  @override
  TransactionType read(BinaryReader reader) {
    return TransactionType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
