import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shared/services/auth_service.dart';
import 'profile_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loading = false;
  bool isSignUpMode = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    setState(() => loading = true);
    try {
      await AuthService.signUpWithEmail(emailCtrl.text.trim(), passwordCtrl.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta criada! Verifique seu email antes de entrar.')),
        );
        setState(() => isSignUpMode = false);
      }
    } on FirebaseAuthException catch (e) {
      _showAuthError(e);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _handleSignIn() async {
    setState(() => loading = true);
    try {
      await AuthService.signInWithEmail(emailCtrl.text.trim(), passwordCtrl.text);
      if (mounted) Navigator.pop(context);
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

  Future<void> _handleSignOut() async {
    setState(() => loading = true);
    await AuthService.signOut();
    await AuthService.signInAnonymously();
    if (mounted) {
      setState(() => loading = false);
      Navigator.pop(context);
    }
  }

  void _showAuthError(FirebaseAuthException e) {
    String message = 'Erro: ${e.message}';
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
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showResendVerificationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Email não verificado'),
        content: const Text('Verifique sua caixa de entrada e spam para confirmar seu email.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
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
            child: const Text('Reenviar email'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAnonymous = user?.isAnonymous ?? true;

    return Scaffold(
      appBar: AppBar(title: Text(isAnonymous ? 'Autenticação' : 'Minha Conta')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: loading
              ? const CircularProgressIndicator()
              : !isAnonymous
              ? _buildProfileCard(user!)
              : _buildAuthForm(),
        ),
      ),
    );
  }

  Widget _buildProfileCard(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            user.photoURL != null ? CircleAvatar(radius: 40, backgroundImage: NetworkImage(user.photoURL!))
                : const Icon(Icons.verified_user, size: 60, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              user.displayName ?? 'Sem nome',
              style: const TextStyle( fontSize: 20, fontWeight: FontWeight.bold)
            ),
            const Icon(Icons.verified_user, size: 40, color: Colors.green),
            Text('Logado como:', style: TextStyle(color: Colors.grey[600])),
            Text(user.email ?? '', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                ).then((_) => setState(() {}));
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar Perfil'),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _handleSignOut,
              child: const Text('Sair da Conta', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAuthForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isSignUpMode ? 'Criar Nova Conta' : 'Entrar no Jogo',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSignUpMode ? _handleSignUp : _handleSignIn,
                child: Text(isSignUpMode ? 'Criar Conta' : 'Entrar'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => setState(() => isSignUpMode = !isSignUpMode),
                  child: Text(isSignUpMode ? 'Já tenho conta' : 'Criar conta'),
                ),
                if (!isSignUpMode)
                  TextButton(
                    onPressed: () async {
                      if (emailCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Digite seu email para redefinir a senha.')),
                        );
                        return;
                      }
                      await AuthService.sendPasswordResetEmail(emailCtrl.text.trim());
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email de redefinição enviado.')),
                        );
                      }
                    },
                    child: const Text('Esqueci a senha'),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}