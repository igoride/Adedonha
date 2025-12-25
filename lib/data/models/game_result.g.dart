// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameResultAdapter extends TypeAdapter<GameResult> {
  @override
  final int typeId = 0;

  @override
  GameResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameResult(
      player: fields[0] as String,
      score: fields[1] as int,
      date: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GameResult obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.player)
      ..writeByte(1)
      ..write(obj.score)
      ..writeByte(2)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
