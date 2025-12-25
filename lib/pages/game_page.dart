import 'dart:async';
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

  Timer? timer;
  int remainingTime = 0;
  String letter = '';

  Map<String, bool> categories = {};

  @override
  void initState() {
    super.initState();
    _listenSettings();
    _listenLetter();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ===================== LISTENERS =====================

  void _listenSettings() {
    service.settingsStream(widget.roomId).listen((settings) {
      if (settings.isEmpty) return;

      final roundTime = settings['roundTime'];

      setState(() {
        categories =
        Map<String, bool>.from(settings['categories']);
      });

      _startTimer(roundTime);
    });
  }

  void _listenLetter() {
    service.letterStream(widget.roomId).listen((l) {
      setState(() => letter = l);
    });
  }

  // ===================== TIMER =====================

  void _startTimer(int seconds) {
    timer?.cancel();
    remainingTime = seconds;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingTime <= 0) {
        t.cancel();
        _finishRound();
      } else {
        setState(() => remainingTime--);
      }
    });
  }

  // ===================== ROUND =====================

  void _finishRound() async {
    await service.updateRoomStatus(
      widget.roomId,
      status: 'review',
    );
  }

  // ===================== UI =====================

  Widget _buildInputs() {
    return Column(
      children: categories.entries
          .where((e) => e.value)
          .map(
            (e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TextField(
            decoration: InputDecoration(
              labelText: e.key.toUpperCase(),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Letra: $letter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Tempo restante: $remainingTime',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInputs(),
            const Spacer(),
            ElevatedButton(
              onPressed: _finishRound,
              child: const Text('STOP'),
            ),
          ],
        ),
      ),
    );
  }
}


