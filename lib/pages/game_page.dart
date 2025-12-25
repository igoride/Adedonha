import 'package:adedonha/shared/services/room_service.dart';
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  final String roomId;
  const GamePage({super.key, required this.roomId});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final service = RoomService();

  final animalCtrl = TextEditingController();
  final cidadeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('STOP Online')),
      body: StreamBuilder(
        stream: service.roomStream(widget.roomId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final room = snapshot.data!.data() as Map<String, dynamic>;
          final status = room['status'];
          final letter = room['currentLetter'] ?? '';

          if (status == 'waiting') {
            return Center(
              child: ElevatedButton(
                onPressed: () =>
                    service.startGame(widget.roomId),
                child: const Text('Iniciar Jogo'),
              ),
            );
          }

          if (status == 'playing') {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Letra: $letter',
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: animalCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Animal'),
                  ),
                  TextField(
                    controller: cidadeCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Cidade'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await service.submitAnswers(
                        widget.roomId,
                        {
                          'animal': animalCtrl.text,
                          'cidade': cidadeCtrl.text,
                        },
                      );
                      await service.stopGame(widget.roomId);
                    },
                    child: const Text('STOP'),
                  ),
                ],
              ),
            );
          }

          // FINISHED
          return Column(
            children: [
              const Text(
                'Resultado',
                style: TextStyle(fontSize: 24),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: service.playersStream(widget.roomId),
                  builder: (context, snap) {
                    if (!snap.hasData) return const SizedBox();
                    final players = snap.data!.docs;

                    return ListView(
                      children: players.map((p) {
                        final d =
                        p.data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(d['name']),
                          trailing:
                          Text('${d['score']} pts'),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await service.calculateScores(widget.roomId);
                },
                child: const Text('Calcular Pontuação'),
              ),
            ],
          );
        },
      ),
    );
  }
}

