import 'package:flutter/material.dart';
import '../shared/services/room_service.dart';
import 'room_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final nameCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  final service = RoomService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stop Online')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Seu nome'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Criar Sala'),
              onPressed: () async {
                final roomId = await service.createRoom(nameCtrl.text);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoomPage(
                      roomId: roomId,
                      playerName: nameCtrl.text,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: codeCtrl,
              decoration: const InputDecoration(labelText: 'Código da sala'),
            ),
            ElevatedButton(
              child: const Text('Entrar na Sala'),
              onPressed: () async {
                final roomId = await service.joinRoom(
                  codeCtrl.text.toUpperCase(),
                  nameCtrl.text,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoomPage(
                      roomId: roomId,
                      playerName: nameCtrl.text,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

