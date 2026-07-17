import 'package:adedonha/main.dart';
import 'package:adedonha/shared/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../shared/services/room_service.dart';
import 'room_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final nameCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final service = RoomService();

  bool loading = false;
  bool showAuthForm = false;
  bool isSignUpMode = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    codeCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  void toggleTheme() {
    if(themeNotifier.value == ThemeMode.light) {
      themeNotifier.value = ThemeMode.dark;
    } else {
      themeNotifier.value = ThemeMode.light;
    }
  }

  Future<void> _handleSignUp() async {
    setState(() => loading = true);
    try {
      await AuthService.signUpWithEmail(
          emailCtrl.text.trim(),
          passwordCtrl.text
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta criada! Verifique seu email antes de entrar.'),
          ),
        );
        setState(() {
          showAuthForm = false;
          isSignUpMode = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      _showAuthError(e);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _handleSignIn() async {
    setState(() => loading = false);
    try {
      final user = await AuthService.signInWithEmail(
          emailCtrl.text.trim(),
          passwordCtrl.text,
      );
      if (nameCtrl.text.isEmpty && user.displayName != null) {
        nameCtrl.text = user.displayName!;
      }
      if (mounted) setState(() => showAuthForm = false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-not-verified') {
        _showResendVerificationDialog();
      } else {
        _showAuthError(e);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'Nenhuma conta encontrada com esse email.';
        break;
      case 'invalid-credential':
        message = 'Email ou senha incorretos.';
        break;
      case 'email-already-in-use':
        message = 'Já existe uma conta com esse email.';
        break;
      case 'weak-password':
        message = 'A senha precisa ter pelo menos 6 caracteres.';
        break;
      case 'invalid-email':
        message = 'Email inválido.';
        break;
      default:
        message = 'Erro: ${e.message}';
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
      );
    }
  }

  void _showResendVerificationDialog() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Email não verificado'),
          content: const Text(
            'Você precisa confirmar seu email antes de entrar.'
            'Verifique sua caixa de entrada e spam.',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
            ),
            TextButton(
                onPressed: () async {
                  await AuthService.resendVerificationEmail();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email de verificação enviado.')),
                    );
                  }
                },
                child: const Text('Reenviar email.')),
          ],
        ),
    );
  }

  Future<void> _handleSignOut() async {
    await AuthService.signOut();
    await AuthService.signInAnonymously();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Stop Online'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAuthCard(),
            const SizedBox(height: 20),
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

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthCard() {
    final user = FirebaseAuth.instance.currentUser;
    final isAnonimous = user?.isAnonymous ?? true;

    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: CircularProgressIndicator(),
      );
    }

    if (!isAnonimous) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.verified_user),
          title: Text(user?.email ?? 'Conta'),
          subtitle: const Text('Email verificado.'),
          trailing: TextButton(
              onPressed: _handleSignOut,
              child: const Text('Sair'),
          ),
        ),
      );
    }

    if (showAuthForm) {
      return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSignUpMode ? 'Criar conta' : 'Entrar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                      onPressed: () => setState(() => showAuthForm = false),
                      icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: isSignUpMode ? _handleSignUp : _handleSignIn, 
                    child: Text(isSignUpMode ? 'Criar conta' : 'Entrar'),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () => setState(() => isSignUpMode = !isSignUpMode), 
                      child: Text(
                        isSignUpMode
                          ? 'Já tenho conta.' : 'Criar conta nova.',
                      ),
                  ),
                  if (!isSignUpMode)
                    TextButton(
                        onPressed: () async {
                          if (emailCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Digite seu email para redefinir a senha.'),
                              ),
                            );
                            return;
                          }
                          await AuthService.sendPasswordResetEmail(
                            emailCtrl.text.trim(),
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Email de redefinição enviado.'), 
                              ),
                            );
                          }
                        } ,
                        child: const Text('Esqueci a senha.')
                    ),
                ],
              )
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
          onPressed: () => setState(() => showAuthForm = true),
          label: const Text('Entrar ou criar conta.'),
          icon: const Icon(Icons.login),
      ),
    );
  }
}

