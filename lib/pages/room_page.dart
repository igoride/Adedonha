import 'package:adedonha/pages/settings_page.dart';
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
      body: StreamBuilder(
        stream: service.roomStream(roomId),
        builder: (context, roomSnap) {
          if (!roomSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final room =
          roomSnap.data!.data() as Map<String, dynamic>;
          final code = room['code'];

          return Column(
            children: [
              // 🔑 CÓDIGO DA SALA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Column(
                  children: [
                    const Text(
                      'Código da Sala',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),

              // 👥 LISTA DE JOGADORES
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
                        final data = players[i].data()
                        as Map<String, dynamic>;
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

              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsPage(roomId: roomId),
                    ),
                  );
                },
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
                        builder: (_) =>
                            GamePage(roomId: roomId),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

