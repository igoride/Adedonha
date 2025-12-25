// ================================
// lib/features/game/game_page_multiplayer.dart
// ================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GamePageMultiplayer extends StatefulWidget {
  final List<String> players;

  const GamePageMultiplayer({super.key, required this.players});

  @override
  State<GamePageMultiplayer> createState() => _GamePageMultiplayerState();
}

class _GamePageMultiplayerState extends State<GamePageMultiplayer> {
  final letras = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
  late String letra;

  int tempo = 60;
  Timer? timer;

  final categorias = ['Nome', 'Cidade', 'Animal', 'Objeto'];
  final Map<String, Map<String, String>> respostas = {};

  @override
  void initState() {
    super.initState();
    letra = letras[Random().nextInt(letras.length)];

    for (var p in widget.players) {
      respostas[p] = {for (var c in categorias) c: ''};
    }

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => tempo--);
      if (tempo == 0) finalizar();
    });
  }

  void finalizar() {
    timer?.cancel();

    Map<String, int> scores = {};

    for (var player in respostas.keys) {
      int total = 0;
      respostas[player]!.forEach((cat, resp) {
        if (resp.isEmpty || !resp.toUpperCase().startsWith(letra)) return;

        final repetida = respostas.entries
            .where((e) => e.key != player)
            .any((e) => e.value[cat]?.toUpperCase() == resp.toUpperCase());

        total += repetida ? 5 : 10;
      });
      scores[player] = total;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Resultado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: scores.entries
              .map((e) => Text('${e.key}: ${e.value} pts'))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Letra: $letra | $tempo s')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: widget.players.map((player) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(player, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...categorias.map((cat) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextField(
                      onChanged: (v) => respostas[player]![cat] = v,
                      decoration: InputDecoration(labelText: cat),
                    ),
                  ))
                ],
              ),
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: finalizar,
        label: const Text('STOP'),
      ),
    );
  }
}
