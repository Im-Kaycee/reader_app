// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArticleAdapter extends TypeAdapter<Article> {
  @override
  final int typeId = 0;

  @override
  Article read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Article()
      ..guid = fields[0] as String
      ..title = fields[1] as String
      ..description = fields[2] as String?
      ..url = fields[3] as String
      ..imageUrl = fields[4] as String?
      ..sourceName = fields[5] as String
      ..sourceId = fields[6] as String
      ..category = fields[7] as String
      ..publishedAt = fields[8] as DateTime
      ..isRead = fields[9] as bool
      ..isBookmarked = fields[10] as bool
      ..cachedAt = fields[11] as DateTime
      ..readTimeMinutes = fields[12] as int;
  }

  @override
  void write(BinaryWriter writer, Article obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.guid)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.sourceName)
      ..writeByte(6)
      ..write(obj.sourceId)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.publishedAt)
      ..writeByte(9)
      ..write(obj.isRead)
      ..writeByte(10)
      ..write(obj.isBookmarked)
      ..writeByte(11)
      ..write(obj.cachedAt)
      ..writeByte(12)
      ..write(obj.readTimeMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
