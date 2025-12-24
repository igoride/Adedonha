import 'package:adedonha/presentation/views/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/game_viewmodel.dart';

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GameViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Score')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Round Score: ${vm.roundScore}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Score: ${vm.totalScore}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              children: vm.answers.map((a) {
                return ListTile(
                  title: Text(a.category),
                  subtitle: Text(a.answer),
                  trailing: Text(a.score.toString()),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              child: const Text('Play Again'),
              onPressed: () {
                context.read<GameViewModel>().resetGame();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}