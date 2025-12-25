// ETAPA 4 – Multiplayer Local Ilimitado
// Cadastro dinâmico de jogadores + rodada compartilhada

// ================================
// lib/features/players/players_page.dart
// ================================

import 'package:flutter/material.dart';
import '../game/game_page_multiplayer.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key});

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final List<TextEditingController> controllers = [];

  void addPlayer() {
    setState(() {
      controllers.add(TextEditingController());
    });
  }

  void startGame() {
    final players = controllers
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => c.text.trim())
        .toList();

    if (players.length < 1) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GamePageMultiplayer(players: players),
      ),
    );
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jogadores')),
      floatingActionButton: FloatingActionButton(
        onPressed: addPlayer,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controllers.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: controllers[i],
                    decoration: InputDecoration(
                      labelText: 'Jogador ${i + 1}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: startGame,
              child: const Text('Iniciar Jogo'),
            )
          ],
        ),
      ),
    );
  }
}

