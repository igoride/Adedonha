import 'dart:async';

import 'package:adedonha/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../shared/services/room_service.dart';
import 'game_page.dart';

class RoomPage extends StatefulWidget {
  final String roomId;
  final String playerName;

  const RoomPage({
    super.key,
    required this.roomId,
    required this.playerName,
  });

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final RoomService service = RoomService();

  StreamSubscription? roomSub;

  @override
  void initState() {
    super.initState();
    _listenRoom();
  }

  void _listenRoom() {
    roomSub = service.roomStream(widget.roomId).listen((snap) {
      final data = snap.data();
      if (data == null) return;

      final status = data['status'];

      if (status == 'playing') {
        _goToGame();
      }
    });
  }

  void _goToGame() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GamePage(
          roomId: widget.roomId,
          playerName: widget.playerName,
        ),
      ),
    );
  }

  @override
  void dispose() {
    roomSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            await service.leaveRoom(widget.roomId);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Sala'),
            centerTitle: true,
          ),
          body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: service.roomStream(widget.roomId),
            builder: (context, roomSnap) {
              if (!roomSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final room = roomSnap.data!.data()!;
              final hostId = room['hostId'];
              final status = room['status'];

              final myUid = FirebaseAuth.instance.currentUser!.uid;
              final isHost = hostId == myUid;

              return Column(
                children: [
                  const SizedBox(height: 16),

                  Text(
                    'Código da sala: ${room['code']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    isHost
                        ? 'Você é o host'
                        : 'Aguardando o host iniciar',
                    style: const TextStyle(fontSize: 16),
                  ),

                  const Divider(height: 32),

                  const Text(
                    'Jogadores',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: service.playersStream(widget.roomId),
                      builder: (context, playersSnap) {
                        if (!playersSnap.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final players = playersSnap.data!.docs;

                        return ListView.builder(
                          itemCount: players.length,
                          itemBuilder: (context, index) {
                            final player = players[index].data();
                            final isHostPlayer =
                                player['uid'] == hostId;

                            return ListTile(
                              leading: Icon(
                                isHostPlayer
                                    ? Icons.star
                                    : Icons.person,
                                color: isHostPlayer
                                    ? Colors.amber
                                    : null,
                              ),
                              title: Text(player['name']),
                              subtitle:
                              isHostPlayer ? const Text('Host') : null,
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const Divider(),

                  if (status == 'lobby' && isHost)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.settings),
                        label: const Text('Configurações'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SettingsPage(roomId: widget.roomId),
                            ),
                          );
                        },
                      ),
                    ),

                  if (isHost && status == 'lobby')
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: () async {
                          await service.startRound(widget.roomId);
                        },
                        child: const Text('Iniciar Rodada'),
                      ),
                    ),

                  if (!isHost && status == 'lobby')
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Aguardando o host iniciar a rodada...',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),

                  if (isHost && status == 'lobby')
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.red,
                        ),
                        icon: const Icon(Icons.delete_forever, color: Colors.white),
                        label: const Text('Apagar Sala', style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Apagar sala?'),
                              content: const Text('Essa ação não pode ser desfeita.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Apagar'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await service.deleteRoom(widget.roomId);
                            if (context.mounted) {
                              Navigator.popUntil(context, (r) => r.isFirst);
                            }
                          }
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        )
    );
  }
}
