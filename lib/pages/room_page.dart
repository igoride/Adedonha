import 'package:adedonha/shared/services/room_service.dart';
import 'package:flutter/material.dart';
import 'game_page.dart';

class RoomPage extends StatelessWidget {
  final String roomId;
  const RoomPage({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final service = RoomService();

    return Scaffold(
      appBar: AppBar(title: const Text('Sala')),
      body: Column(
        children: [
          // 🔥 LISTA DE JOGADORES (tempo real)
          Expanded(
            child: StreamBuilder(
              stream: service.playersStream(roomId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final players = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (_, i) {
                    final data =
                    players[i].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['name']),
                      trailing:
                      Text('${data['score']} pts'),
                    );
                  },
                );
              },
            ),
          ),

          // 🚀 BOTÃO IR PARA O JOGO
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              child: const Text('Ir para o Jogo'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GamePage(roomId: roomId),
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
