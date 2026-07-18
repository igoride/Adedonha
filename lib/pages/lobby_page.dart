import 'package:adedonha/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../shared/services/room_service.dart';
import 'login_page.dart';
import 'room_page.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  final nameCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  final service = RoomService();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.displayName != null) {
        nameCtrl.text = user.displayName!;
      }
    } catch (e) {
      debugPrint("Erro no initState Auth: $e");
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    codeCtrl.dispose();
    super.dispose();
  }

  void _navigateToRoom(String roomId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomPage(
          roomId: roomId,
          playerName: nameCtrl.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Salas de Jogo'),
          actions: [
            StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  final isAnonymous = user?.isAnonymous ?? true;

                  if (!isAnonymous && user?.photoURL != null) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfilePage()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user!.photoURL!),
                          radius: 18,
                        ),
                      ),
                    );
                  }
                  return IconButton(
                      icon: Icon(
                          isAnonymous ? Icons.account_circle_outlined : Icons
                              .account_circle),
                      tooltip: isAnonymous
                          ? 'Entrar / Cadastrar'
                          : 'Meu Perfil',
                      onPressed: () {
                        if (isAnonymous) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfilePage()),
                          );
                        }
                      }
                  );
                }
            )
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Identifique-se',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Seu apelido no jogo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Seção: Criar Sala
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.add_box_rounded),
                label: const Text(
                    'Criar Nova Sala', style: TextStyle(fontSize: 16)),
                onPressed: () async {
                  if (nameCtrl.text
                      .trim()
                      .isEmpty) {
                    _showWarningSnackBar(
                        'Digite seu apelido antes de criar uma sala.');
                    return;
                  }
                  setState(() => loading = true);
                  try {
                    final roomId = await service.createRoom(nameCtrl.text);
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RoomPage(
                                roomId: roomId,
                                playerName: nameCtrl.text,
                              ),
                        ),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => loading = false);
                  }
                },
              ),

              const SizedBox(height: 24),

              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OU', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Entrar em Sala Existente',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: codeCtrl,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Código de 4 ou 6 letras',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Entrar na Sala'),
                        onPressed: () async {
                          if (nameCtrl.text
                              .trim()
                              .isEmpty) {
                            _showWarningSnackBar(
                                'Digite seu apelido antes de entrar.');
                            return;
                          }
                          if (codeCtrl.text
                              .trim()
                              .isEmpty) {
                            _showWarningSnackBar('Insira o código da sala.');
                            return;
                          }
                          setState(() => loading = true);
                          try {
                            final roomId = await service.joinRoom(
                              codeCtrl.text.toUpperCase().trim(),
                              nameCtrl.text,
                            );
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RoomPage(
                                        roomId: roomId,
                                        playerName: nameCtrl.text,
                                      ),
                                ),
                              );
                            }
                          } catch (e) {
                            _showWarningSnackBar(
                                'Erro ao tentar conectar à sala.');
                          } finally {
                            if (mounted) setState(() => loading = false);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              //--------------------
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('SALAS DISPONÍVEIS',
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 10),

          Expanded(
            child: Builder(
              builder: (context) {
                try {
                  final roomStream = service.getAvailableRooms();

                  return StreamBuilder<List<dynamic>>(
                    stream: roomStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Erro no Stream: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final rooms = snapshot.data;
                      if (rooms == null || rooms.isEmpty) {
                        return const Center(child: Text('Nenhuma sala disponível.'));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];

                          final String roomId = room.id;
                          final String roomCode = room.code;
                          final String hostName = room.hostName;
                          final int playersCount = room.playersCount;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            elevation: 2,
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                child: Icon(Icons.videogame_asset),
                              ),
                              title: Text('Sala de $hostName', style: TextStyle(color: Colors.white)),
                              subtitle: Text('Código: $roomCode * $playersCount jogadores'),
                              trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (nameCtrl.text.trim().isEmpty) {
                                      _showWarningSnackBar('Digite seu apelido antes de entrar');
                                      return;
                                    }
                                    setState(() => loading = true);
                                    try {
                                      final String id = await service.joinRoom(
                                          roomCode,
                                          nameCtrl.text,
                                      );

                                      if (mounted) {
                                        _navigateToRoom(id);
                                      }
                                    } catch(e) {
                                      _showWarningSnackBar('Erro ao entrar na sala.');
                                    } finally {
                                      if (mounted) setState(() => loading = false);
                                    }
                                  },
                                  child: const Text('Entrar'),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                } catch (e) {
                  return Center(
                    child: Text(
                      'O método getAvailableRooms() quebrou:\n$e',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
              },
            ),
          )
            ],
          ),
        ),
      );
    } catch (globalError) {
      return Scaffold(
        body: Center(
          child: Text('$globalError'),
        ),
      );
    }
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.amber[800]),
    );
  }
}