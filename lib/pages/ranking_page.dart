
import 'dart:async';

import 'package:adedonha/pages/game_page.dart';
import 'package:adedonha/pages/room_page.dart';
import 'package:adedonha/shared/services/room_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RankingPage extends StatefulWidget {
  final String roomId;
  final String playerName;

  const RankingPage({
    super.key,
    required this.roomId,
    required this.playerName,
  });

  @override
  State<RankingPage> createState() => _RankingPage();
}

class _RankingPage extends State<RankingPage> {
  final RoomService service = RoomService();

  StreamSubscription? roomSub;
  StreamSubscription? roundSub;

  String currentRoundId = '';

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GamePage(roomId: widget.roomId, playerName: widget.playerName,),
          ),
        );
      }

      if (status == 'lobby') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RoomPage(roomId: widget.roomId, playerName: widget.playerName,),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Ranking')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.roomId)
            .snapshots(),
        builder: (context, roomSnap) {
          if (!roomSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final roomData = roomSnap.data!.data()!;
          final hostId = roomData['hostId'];
          final isHost = myUid == hostId;
          return Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('rooms')
                      .doc(widget.roomId)
                      .collection('players')
                      .orderBy('score', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return ListTile(
                          leading: Text('#${index + 1}'),
                          title: Text(data['name']),
                          trailing: Text('${data['score'] ?? 0} pts'),
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              if (isHost)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () async {
                      final service = RoomService();
                      final hasNext = await service.hasNextRound(widget.roomId);

                      if (hasNext) {
                        await service.startRound(widget.roomId);
                        await service.setRoomStatus(widget.roomId, 'playing');
                      } else {
                        await service.setRoomStatus(widget.roomId, 'lobby');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Próxima Rodada'),
                  ),
                ),
              if (!isHost )
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text (
                    'Aguardando o host iniciar a próxima rodada...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
