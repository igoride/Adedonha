import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../shared/services/room_service.dart';

class SettingsPage extends StatefulWidget {
  final String roomId;

  const SettingsPage({super.key, required this.roomId});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final RoomService service = RoomService();

  int roundTime = 120;
  int rounds = 3;

  Map<String, bool> categories = {
    'Animal': true,
    'Nome': true,
    'CEP': true,
    'Objeto': true,
    "MSE": true,
    "Filme": true,
    "Musica": true,
  };

  bool initialized = false;
  final TextEditingController newCategoryCtrl = TextEditingController();

  @override
  void dispose() {
    newCategoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: service.settingsStream(widget.roomId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          if (!initialized) {
            roundTime = data['roundTime'] ?? roundTime;
            rounds = data['rounds'] ?? rounds;
            categories =
            Map<String, bool>.from(data['categories'] ?? categories);
            initialized = true;
          }

          final hostId = data['hostId'];
          final status = data['status'];

          final isHost = hostId == myUid;
          final canEdit = isHost && status == 'lobby';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _sectionTitle('Tempo da Rodada'),
                Slider(
                  min: 30,
                  max: 300,
                  divisions: 27,
                  label: '$roundTime s',
                  value: roundTime.toDouble(),
                  onChanged: canEdit
                      ? (v) => setState(() => roundTime = v.toInt())
                      : null,
                ),

                const SizedBox(height: 16),

                _sectionTitle('Número de Rodadas'),
                Slider(
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '$rounds',
                  value: rounds.toDouble(),
                  onChanged: canEdit
                      ? (v) => setState(() => rounds = v.toInt())
                      : null,
                ),

                const SizedBox(height: 16),

                _sectionTitle('Categorias'),

                ...categories.entries.map(
                      (e) => CheckboxListTile(
                    title: Text(e.key),
                    value: e.value,
                    onChanged: canEdit
                        ? (v) =>
                        setState(() => categories[e.key] = v ?? false)
                        : null,
                  ),
                ),

                if (canEdit)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: newCategoryCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Nova categoria',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          final name = newCategoryCtrl.text.trim();
                          if (name.isNotEmpty &&
                              !categories.containsKey(name)) {
                            setState(() {
                              categories[name] = true;
                              newCategoryCtrl.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                if (!isHost)
                  const Text(
                    'Apenas o host pode alterar as configurações.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),

                if (isHost && status != 'lobby')
                  const Text(
                    'As configurações só podem ser alteradas no lobby.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),

                if (canEdit)
                  ElevatedButton(
                    onPressed: () async {
                      await service.saveSettings(
                        widget.roomId,
                        roundTime,
                        rounds,
                        categories,
                      );
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text('Salvar Configurações'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
