import 'package:adedonha/data/repositories/game_repository_impl.dart';
import 'package:adedonha/data/services/letter_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/views/home_screen.dart';
import 'presentation/viewmodels/settings_viewmodel.dart';
import 'presentation/viewmodels/game_viewmodel.dart';
import 'presentation/viewmodels/multiplayer_viewmodel.dart';

import 'domain/usecases/generate_letter_usecase.dart';
import 'domain/usecases/calculate_score_usecase.dart';
import 'infrastructure/network/websocket_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = GameRepositoryImpl(LetterService());

    return MultiProvider(
      providers: [
        /// SETTINGS (global)
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(),
        ),

        /// WEBSOCKET SERVICE (single instance)
        Provider(
          create: (_) => WebSocketService(),
          dispose: (_, service) => service.dispose(),
        ),

        /// MULTIPLAYER (depends on WebSocketService)
        ChangeNotifierProvider(
          create: (context) => MultiplayerViewModel(
            context.read<WebSocketService>(),
          ),
        ),

        /// GAME (depends on Settings + Multiplayer)
        ChangeNotifierProvider(
          create: (context) => GameViewModel(
            generateLetter: GenerateLetterUseCase(repository),
            calculateScore: CalculateScoreUseCase(repository),
            settings: context.read<SettingsViewModel>(),
            multiplayer: context.read<MultiplayerViewModel>(),
          ),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}
