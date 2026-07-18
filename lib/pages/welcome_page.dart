import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import 'lobby_page.dart';
import 'login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _toggleTheme() {
    if (themeNotifier.value == ThemeMode.light) {
      themeNotifier.value = ThemeMode.dark;
    } else {
      themeNotifier.value = ThemeMode.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAnonymous = user?.isAnonymous ?? true;

    return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentTheme, _) {

          final isDark = currentTheme == ThemeMode.dark;
          final Color appBarIconColor = isDark
          ? Colors.amber : Colors.black;
          final primaryGradient = isDark
              ? const [Color(0xFF1E1B4B), Color(0xFF311042)] // Cores escuras para o Dark Mode
              : const [Color(0xFF4361EE), Color(0xFF3F37C9)];

          return Scaffold(
            extendBodyBehindAppBar: true, //O plano de fundo se extende até debeixo da appbar

              //---- Topo----
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: appBarIconColor),
              actions: [
                IconButton(
                  icon: const Icon(Icons.brightness_6),
                  onPressed: _toggleTheme,
                ),
              ],
            ),

            body: Stack(
              children: [

                // Onda
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height * 0.30,//260, // Ajustado para não cobrir a logo
                  child: ClipPath(
                    clipper: WaveClipper(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: primaryGradient,
                        ),
                      ),
                    ),
                  ),
                ),

                // Conteudo
                SafeArea(
                  //Centraliza o bloco
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1500, //Tamanho do bloco
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                              child: Column(
                                children: [
                                    //Logo
                                  Column(
                                    children: [
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                                          borderRadius: BorderRadius.circular(32),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            )
                                          ],
                                        ),
                                        child: Icon(
                                            Icons.videogame_asset,
                                            size: 75,
                                            color: isDark ? const Color(0xFF7F7CAF) : const Color(0xFF3F37C9)
                                        ),
                                      ),

                                      const SizedBox(height: 24),

                                      Text(
                                        'Stop Online',
                                        style: TextStyle(
                                          fontSize: 34,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        'O clássico jogo de Adedonha\ncom seus amigos!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: isDark ? Colors.grey[400] : const Color(0xFF7A7A7A),
                                            height: 1.4
                                        ),
                                      ),
                                    ],
                                  ),


                                  const SizedBox(height: 32),

                                  // Botões
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      //Botão Jogar
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF3F37C9),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            elevation: 1,
                                          ),
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LobbyPage()));
                                          },
                                          icon: const Icon(Icons.sports_esports),
                                          label: const Text('Jogar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      //Botão Login
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: isDark ? const Color(0xFF9B97F4) : const Color(0xFF3F37C9),
                                            side: BorderSide(
                                              color: isDark ? const Color(0xFF5A54D6) : const Color(0xFF3F37C9),
                                                width: 2
                                            ),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          ),
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                                          },
                                          icon: const Icon(Icons.person_outline),
                                          label: const Text('Entrar ou criar conta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        ),
                                      ),

                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            )

          );
        }
    );

  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.75); // Começa na esquerda

    // Primeira curva da onda
    var firstControlPoint = Offset(size.width * 0.25, size.height * 0.65);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.75);
    path.quadraticBezierTo(
        firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy
    );

    // Segunda curva da onda (efeito fluido)
    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.85);
    var secondEndPoint = Offset(size.width, size.height * 0.70);
    path.quadraticBezierTo(
        secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy
    );

    path.lineTo(size.width, 0); // Sobe até o topo direito
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}