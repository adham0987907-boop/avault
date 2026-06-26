import 'package:hive/hive.dart';

part 'vault_item_model.g.dart';

@HiveType(typeId: 0)
class VaultItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String encryptedFileName;

  @HiveField(2)
  final String cleartextOriginalName;

  @HiveField(3)
  final String fileExtension;

  @HiveField(4)
  final int fileSizeBytes;

  @HiveField(5)
  final DateTime registrationTimestamp;

  @HiveField(6)
  final bool isFavorite;

  @HiveField(7)
  final bool isArchivedInRecycleBin;

  @HiveField(8)
  final DateTime? recycleBinIngestionTimestamp;

  @HiveField(9)
  final String targetAlbumName;

  VaultItemModel({
    required this.id,
    required this.encryptedFileName,
    required this.cleartextOriginalName,
    required this.fileExtension,
    required this.fileSizeBytes,
    required this.registrationTimestamp,
    this.isFavorite = false,
    this.isArchivedInRecycleBin = false,
    this.recycleBinIngestionTimestamp,
    this.targetAlbumName = 'Root',
  });
}
