import 'package:adedonha/shared/services/room_service.dart';
import 'package:flutter/material.dart';
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
            // 👤 NOME
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Seu nome',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ➕ CRIAR SALA
            ElevatedButton(
              child: const Text('Criar Sala'),
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;

                final roomId =
                await service.createRoom(nameCtrl.text);

                if (!mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoomPage(roomId: roomId),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // 🔑 CÓDIGO
            TextField(
              controller: codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Código da sala',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // 🔗 ENTRAR NA SALA
            ElevatedButton(
              child: const Text('Entrar na Sala'),
              onPressed: () async {
                if (nameCtrl.text.isEmpty ||
                    codeCtrl.text.isEmpty) return;

                final roomId = await service.joinRoom(
                  codeCtrl.text.toUpperCase(),
                  nameCtrl.text,
                );

                if (!mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoomPage(roomId: roomId),
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
