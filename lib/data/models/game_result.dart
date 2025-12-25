// ETAPA 3 – Pontuação oficial + Ranking local (Hive)
// Arquivos principais (simplificado para facilitar integração)

// pubspec.yaml (adicione)
// dependencies:
//   hive: ^2.2.3
//   hive_flutter: ^1.1.0

// ================================
// lib/data/models/game_result.dart
// ================================

import 'package:hive/hive.dart';

part 'game_result.g.dart';

@HiveType(typeId: 0)
class GameResult extends HiveObject {
  @HiveField(0)
  String player;

  @HiveField(1)
  int score;

  @HiveField(2)
  DateTime date;

  GameResult({required this.player, required this.score, required this.date});
}


