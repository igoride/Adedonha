import 'dart:async';

import 'package:adedonha/pages/ranking_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../shared/services/room_service.dart';
import '../widget/vote_tile.dart';
import 'game_page.dart';

class VotingPage extends StatefulWidget {
  final String roomId;
  final String roundId;
  final String playerName;

  const VotingPage({
    super.key,
    required this.roomId,
    required this.roundId,
    required this.playerName,
  });

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  final RoomService service = RoomService();

  StreamSubscription? roomSub;
  StreamSubscription? roundSub;

  bool votingFinished = false;

  @override
  void initState() {
    super.initState();
    _listenRoom();
    _listenRound();
  }

  void _listenRoom() {
    roomSub = service.roomStream(widget.roomId).listen((snap) {
      final data = snap.data();
      if (data == null) return;

      final status = data['status'];
      final nextRoundId = data['currentRoundId'];

      if (status == 'playing' && !votingFinished) {
        votingFinished = true;
        _goToGame(nextRoundId);
      }

      if (status == 'waiting' && !votingFinished) {
        votingFinished = true;
        Navigator.popUntil(context, (r) => r.isFirst);
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

  void _listenRound() {
    roundSub = service
        .roundStream(widget.roomId, widget.roundId)
        .listen((snap) {
      final data = snap.data();
      if (data == null) return;

      if (data['status'] == 'finished' && !votingFinished) {
        votingFinished = true;
      }

    });
  }

  void _goToGame(String nextRoundId) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GamePage(
          roomId: widget.roomId,
          playerName: '',
        ),
      ),
    );
  }

  @override
  void dispose() {
    roomSub?.cancel();
    roundSub?.cancel();
    super.dispose();
  }

  Map<String, List<Map<String, dynamic>>> _groupAnswersByCategory(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
      ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final doc in docs) {
      final data = doc.data();
      final answers = Map<String, dynamic>.from(data['answers'] ?? {});
      final playerId = data['playerId'];

      for (final entry in answers.entries) {
        final category = entry.key;
        final answer = entry.value.toString().trim().toUpperCase();

        if (answer.isEmpty) continue;

        grouped.putIfAbsent(category, () => []);

        final exists = grouped[category]!.any((a) => a['answer'] == answer);
        if (!exists) {
          grouped[category]!.add({
            'answer': answer,
            'playerId': playerId,
          });
        }
      }
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Votação'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.answersStream(widget.roomId, widget.roundId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text('Nenhuma resposta enviada'),
            );
          }

          final grouped = _groupAnswersByCategory(docs);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: grouped.entries.map((categoryEntry) {
                    final category = categoryEntry.key;
                    final answers = categoryEntry.value;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),

                            ...answers.map((item) {
                              return VoteTile(
                                roomId: widget.roomId,
                                roundId: widget.roundId,
                                category: category,
                                answer: item['answer'],
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(widget.roomId)
                    .get(),
                builder: (context, snap) {
                  if (!snap.hasData) return const SizedBox();

                  final isHost =
                      snap.data!['hostId'] == myUid;

                  if (!isHost) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Aguardando o host finalizar a votação...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () async {
                        await service.calculateScores(widget.roomId, widget.roundId);
                        await service.setRoomStatus(widget.roomId, 'ranking');
                      },
                      child: const Text('Finalizar Votação'),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
