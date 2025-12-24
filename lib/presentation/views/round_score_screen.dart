import 'package:adedonha/presentation/viewmodels/game_viewmodel.dart';
import 'package:adedonha/presentation/views/game_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoundScoreScreen extends StatelessWidget {
  const RoundScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GameViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Round ${vm.currentRound} Score'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Round Score: ${vm.roundScore}',
                  style: const TextStyle(
                    fontSize: 20,
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
            child: ListView.builder(
              itemCount: vm.answers.length,
              itemBuilder: (_, index) {
                final a = vm.answers[index];
                return ListTile(
                  title: Text(a.category),
                  subtitle: Text(a.answer),
                  trailing: Text(a.score.toString()),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              child: Text(
                vm.currentRound >= vm.settings.totalRounds
                    ? 'Finish Game'
                    : 'Next Round',
              ),
              onPressed: () {
                vm.nextRoundOrFinish();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GameScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
