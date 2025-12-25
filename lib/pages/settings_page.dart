import 'package:adedonha/shared/services/room_service.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final String roomId;
  const SettingsPage({super.key, required this.roomId});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final service = RoomService();

  int roundTime = 120;
  int rounds = 3;

  Map<String, bool> categories = {
    'animal': true,
    'cidade': true,
    'objeto': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: StreamBuilder(
        stream: service.settingsStream(widget.roomId),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final data = snapshot.data!;
            roundTime = data['roundTime'] ?? roundTime;
            rounds = data['rounds'] ?? rounds;
            categories = Map<String, bool>.from(
              data['categories'] ?? categories,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ⏱️ TEMPO
              Text('Tempo da rodada: $roundTime s'),
              Slider(
                value: roundTime.toDouble(),
                min: 30,
                max: 300,
                divisions: 9,
                label: '$roundTime',
                onChanged: (v) =>
                    setState(() => roundTime = v.toInt()),
              ),

              const SizedBox(height: 16),

              // 🔁 RODADAS
              Text('Rodadas: $rounds'),
              Slider(
                value: rounds.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: '$rounds',
                onChanged: (v) =>
                    setState(() => rounds = v.toInt()),
              ),

              const Divider(),

              const Text(
                'Categorias',
                style: TextStyle(fontSize: 18),
              ),

              ...categories.keys.map(
                    (key) => SwitchListTile(
                  title: Text(key.toUpperCase()),
                  value: categories[key]!,
                  onChanged: (v) =>
                      setState(() => categories[key] = v),
                ),
              ),

              const SizedBox(height: 24),

              // 💾 SALVAR
              ElevatedButton(
                onPressed: () async {
                  await service.saveSettings(
                    widget.roomId,
                    roundTime: roundTime,
                    rounds: rounds,
                    categories: categories,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar Configurações'),
              ),
            ],
          );
        },
      ),
    );
  }
}
