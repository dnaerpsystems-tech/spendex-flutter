import 'package:hive/hive.dart';
import '../../../features/accounts/data/models/account_model.dart';
import '../../../core/constants/app_constants.dart';

/// Hive TypeAdapter for AccountModel
class AccountModelAdapter extends TypeAdapter<AccountModel> {
  @override
  final int typeId = 2;

  @override
  AccountModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return AccountModel(
      id: fields[0] as String,
      name: fields[1] as String,
      type: AccountType.values[fields[2] as int],
      balance: fields[3] as int,
      currency: fields[4] as String? ?? 'INR',
      bankName: fields[5] as String?,
      accountNumber: fields[6] as String?,
      icon: fields[7] as String?,
      color: fields[8] as String?,
      creditLimit: fields[9] as int?,
      isDefault: fields[10] as bool? ?? false,
      isActive: fields[11] as bool? ?? true,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AccountModel obj) {
    writer
      ..writeByte(14) // Number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type.index)
      ..writeByte(3)
      ..write(obj.balance)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.bankName)
      ..writeByte(6)
      ..write(obj.accountNumber)
      ..writeByte(7)
      ..write(obj.icon)
      ..writeByte(8)
      ..write(obj.color)
      ..writeByte(9)
      ..write(obj.creditLimit)
      ..writeByte(10)
      ..write(obj.isDefault)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Hive TypeAdapter for AccountType enum
class AccountTypeAdapter extends TypeAdapter<AccountType> {
  @override
  final int typeId = 11;

  @override
  AccountType read(BinaryReader reader) {
    return AccountType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, AccountType obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
