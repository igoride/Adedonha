import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _user = FirebaseAuth.instance.currentUser;
  final _nameCtrl = TextEditingController();
  String? _selectedAvatarUrl;
  bool _loading = false;

  final List<String> _avatars = [
    'https://api.dicebear.com/7.x/bottts/png?seed=Felix',
    'https://api.dicebear.com/7.x/bottts/png?seed=Aneka',
    'https://api.dicebear.com/7.x/bottts/png?seed=Jack',
    'https://api.dicebear.com/7.x/bottts/png?seed=Luna',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = _user?.displayName ?? '';
    _selectedAvatarUrl = _user?.photoURL ?? _avatars.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O nome de usuário não pode ser vazio.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _user?.updateDisplayName(_nameCtrl.text.trim());
      await _user?.updatePhotoURL(_selectedAvatarUrl);

      await _user?.reload();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null || _user!.isAnonymous) {
      return Scaffold(
        appBar: AppBar(title: const Text('Configurar Perfil')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Você precisa estar logado com uma conta de Email para configurar seu perfil permanente.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          if (!_loading)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.deepPurple.withOpacity(0.1),
              backgroundImage: _selectedAvatarUrl != null
                  ? NetworkImage(_selectedAvatarUrl!)
                  : null,
            ),
            const SizedBox(height: 24),

            const Text(
              'Escolha seu Avatar:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: _avatars.length,
                itemBuilder: (context, index) {
                  final avatar = _avatars[index];
                  final isSelected = _selectedAvatarUrl == avatar;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatarUrl = avatar),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.deepPurple : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: NetworkImage(avatar),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome de Usuário / Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Salvar Alterações'),
              ),
            )
          ],
        ),
      ),
    );
  }
}