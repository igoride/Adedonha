// ================================
// lib/features/ranking/ranking_page.dart
// ================================

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/game_result.dart';

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ranking')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<GameResult>('ranking').listenable(),
        builder: (context, box, _) {
          final results = box.values.toList()
            ..sort((a, b) => b.score.compareTo(a.score));

          if (results.isEmpty) {
            return const Center(child: Text('Nenhuma partida registrada'));
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (_, i) {
              final r = results[i];
              return ListTile(
                leading: Text('#${i + 1}'),
                title: Text(r.player),
                trailing: Text('${r.score} pts'),
                subtitle: Text(r.date.toString()),
              );
            },
          );
        },
      ),
    );
  }
}
