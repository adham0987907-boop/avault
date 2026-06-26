part of 'vault_item_model.dart';

class VaultItemModelAdapter extends TypeAdapter<VaultItemModel> {
  @override
  final int typeId = 0;

  @override
  VaultItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaultItemModel(
      id: fields[0] as String,
      encryptedFileName: fields[1] as String,
      cleartextOriginalName: fields[2] as String,
      fileExtension: fields[3] as String,
      fileSizeBytes: fields[4] as int,
      registrationTimestamp: fields[5] as DateTime,
      isFavorite: fields[6] as bool,
      isArchivedInRecycleBin: fields[7] as bool,
      recycleBinIngestionTimestamp: fields[8] as DateTime?,
      targetAlbumName: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VaultItemModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.encryptedFileName)
      ..writeByte(2)
      ..write(obj.cleartextOriginalName)
      ..writeByte(3)
      ..write(obj.fileExtension)
      ..writeByte(4)
      ..write(obj.fileSizeBytes)
      ..writeByte(5)
      ..write(obj.registrationTimestamp)
      ..writeByte(6)
      ..write(obj.isFavorite)
      ..writeByte(7)
      ..write(obj.isArchivedInRecycleBin)
      ..writeByte(8)
      ..write(obj.recycleBinIngestionTimestamp)
      ..writeByte(9)
      ..write(obj.targetAlbumName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaultItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
