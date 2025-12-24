import 'package:adedonha/presentation/views/round_score_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/game_viewmodel.dart';
import 'score_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  final List<String> categories = const [
    'Name',
    'Animal',
    'City',
    'Object',
    'Food',
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GameViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.roundFinished) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const RoundScoreScreen(),
          ),
        );
      } else if (vm.gameFinished) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ScoreScreen(),
          ),
        );
      }
    });

    if (vm.currentLetter.isEmpty && !vm.gameFinished) {
      vm.startGame();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Round ${vm.currentRound}/${vm.settings.totalRounds}'),
        actions: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('⏱ ${vm.timeLeft}s'),
                Text('🏆 ${vm.totalScore}'),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Text(vm.currentLetter, style: Theme.of(context).textTheme.displayLarge),
          Expanded(
            child: ListView.builder(
              itemCount: vm.answers.length,
              itemBuilder: (_, index) {
                return TextField(
                  onChanged: (value) => vm.updateAnswer(index, value),
                  decoration: InputDecoration(
                    labelText: vm.answers[index].category,
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              vm.finishRound();
            },
            child: const Text('STOP'),
          )
        ],
      ),
    );
  }
}
