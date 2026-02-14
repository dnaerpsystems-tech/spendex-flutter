import 'package:hive/hive.dart';
import '../../../features/categories/data/models/category_model.dart';
import '../../../core/constants/app_constants.dart';

/// Hive TypeAdapter for CategoryModel
class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 4;

  @override
  CategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return CategoryModel(
      id: fields[0] as String,
      name: fields[1] as String,
      type: CategoryType.values[fields[2] as int],
      icon: fields[3] as String?,
      color: fields[4] as String?,
      parentId: fields[5] as String?,
      isSystem: fields[6] as bool? ?? false,
      sortOrder: fields[7] as int? ?? 0,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer
      ..writeByte(10) // Number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type.index)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.color)
      ..writeByte(5)
      ..write(obj.parentId)
      ..writeByte(6)
      ..write(obj.isSystem)
      ..writeByte(7)
      ..write(obj.sortOrder)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Hive TypeAdapter for CategoryType enum
class CategoryTypeAdapter extends TypeAdapter<CategoryType> {
  @override
  final int typeId = 13;

  @override
  CategoryType read(BinaryReader reader) {
    return CategoryType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, CategoryType obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
