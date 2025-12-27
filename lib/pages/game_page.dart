import 'dart:async';

import 'package:adedonha/pages/ranking_page.dart';
import 'package:flutter/material.dart';
import '../shared/services/room_service.dart';
import 'voting_page.dart';

class GamePage extends StatefulWidget {
  final String roomId;
  final String playerName;

  const GamePage({
    super.key,
    required this.roomId,
    required this.playerName,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final RoomService service = RoomService();

  Timer? timer;
  StreamSubscription? roomSub;
  StreamSubscription? roundSub;

  int remainingTime = 0;
  String letter = '';
  String currentRoundId = '';
  bool submitted = false;

  Map<String, TextEditingController> answerCtrls = {};

  @override
  void initState() {
    super.initState();
    _listenRoom();
  }

  void _listenRoom() {
    roomSub = service.roomStream(widget.roomId).listen((snap) async {
      final data = snap.data();
      if (data == null) return;

      final status = data['status'];
      final roundId = data['currentRoundId'];

      if (status == 'playing' && currentRoundId != roundId) {
        currentRoundId = roundId;
        await _startRound(roundId);
      }
      if (status == 'voting') {
        if (!submitted) {
          _submitAnswers();
        }
        _goToVoting();
      }
      if (status == 'ranking') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RankingPage(roomId: widget.roomId, playerName: widget.playerName,),
          ),
        );
      }
    });
  }

  Future<void> _startRound(String roundId) async {
    final snap =
    await service.roundStream(widget.roomId, roundId).first;
    final data = snap.data();
    if (data == null) return;

    letter = data['letter'];
    remainingTime = data['duration'];

    final categories = List<String>.from(data['categories']);

    answerCtrls.clear();
    for (final c in categories) {
      answerCtrls[c] = TextEditingController();
    }

    _startTimer();
    setState(() {});
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingTime <= 0) {
        t.cancel();
        _submitAnswers();
      } else {
        setState(() => remainingTime--);
      }
    });
  }

  Future<void> _submitAnswers() async {
    if (submitted) return;
    submitted = true;
    setState(() {});

    timer?.cancel();

    final answers = answerCtrls.map(
          (k, v) => MapEntry(k, v.text.trim()),
    );

    await service.submitAnswers(
      widget.roomId,
      currentRoundId,
      widget.playerName,
      answers,
    );

    await service.stopRound(widget.roomId, currentRoundId);
    await service.setRoomStatus(widget.roomId, 'voting');
  }

  void _goToVoting() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VotingPage(
          roomId: widget.roomId,
          roundId: currentRoundId,
          playerName: widget.playerName,
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    roomSub?.cancel();
    roundSub?.cancel();
    for (final c in answerCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Letra: $letter'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Tempo restante: $remainingTime s',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: answerCtrls.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextField(
                      controller: e.value,
                      decoration: InputDecoration(labelText: e.key),
                    ),
                  );
                }).toList(),
              ),
            ),

            ElevatedButton(
              onPressed: submitted ? null : _submitAnswers,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(submitted ? 'Aguardando...' : 'STOP'),
            ),

          ],
        ),
      ),
    );
  }
}
