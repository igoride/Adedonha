import 'dart:async';
import 'package:adedonha/domain/entities/network_message.dart';
import 'package:adedonha/presentation/viewmodels/multiplayer_viewmodel.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/category_answer.dart';
import '../../domain/usecases/generate_letter_usecase.dart';
import '../../domain/usecases/calculate_score_usecase.dart';
import 'settings_viewmodel.dart';

class GameViewModel extends ChangeNotifier {
  final GenerateLetterUseCase generateLetter;
  final CalculateScoreUseCase calculateScore;
  final SettingsViewModel settings;
  final MultiplayerViewModel multiplayer;

  bool _gameFinished = false;
  bool get gameFinished => _gameFinished;

  bool _roundFinished = false;
  bool get roundFinished => _roundFinished;

  String currentLetter = '';
  List<CategoryAnswer> answers = [];

  Timer? _timer;
  int timeLeft = 0;

  int currentRound = 1;

  int roundScore = 0;
  int totalScore = 0;

  GameViewModel({
    required this.generateLetter,
    required this.calculateScore,
    required this.settings,
    required this.multiplayer,
  });

  void startGame() {
    _gameFinished = false;
    _roundFinished = false;
    currentRound = 1;
    totalScore = 0;
    _startRound();
  }

  void _startRound() {
    currentLetter = generateLetter();
    timeLeft = settings.timePerRound;
    if (multiplayer.isHost) {
      currentLetter = generateLetter();

      multiplayer.sendMessage(
        NetworkMessage(
          type: MessageType.startRound,
          payload: {
            'letter': currentLetter,
            'round': currentRound,
            'time': timeLeft,
          },
        ),
      );
    }
    answers = settings.categories
        .map((c) => CategoryAnswer(category: c, answer: ''))
        .toList();

    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        timeLeft--;

        if (timeLeft <= 0) {
          finishRound();
        }

        notifyListeners();
      },
    );
  }

  void updateAnswer(int index, String value) {
    answers[index] = CategoryAnswer(
      category: answers[index].category,
      answer: value,
    );
  }

  void finishRound() {
    if (_roundFinished) return;

    _timer?.cancel();

    roundScore = 0;

    // HOST calculates scores
    if (multiplayer.isHost) {
      answers = answers.map((a) {
        final score = calculateScore(a.answer, currentLetter);
        roundScore += score;

        return CategoryAnswer(
          category: a.category,
          answer: a.answer,
          score: score,
        );
      }).toList();

      totalScore += roundScore;

      multiplayer.sendMessage(
        NetworkMessage(
          type: MessageType.roundResult,
          payload: {
            'roundScore': roundScore,
            'totalScore': totalScore,
            'answers': answers
                .map((a) => {
              'category': a.category,
              'answer': a.answer,
              'score': a.score,
            })
                .toList(),
          },
        ),
      );
    }

    _roundFinished = true;
    notifyListeners();
  }

  void nextRoundOrFinish() {
    _roundFinished = false;

    if (currentRound >= settings.totalRounds) {
      _finishGame();
    } else {
      currentRound++;
      _startRound();
    }

    notifyListeners();
  }

  void _finishGame() {
    _gameFinished = true;
    notifyListeners();
  }

  void resetGame() {
    _timer?.cancel();

    currentLetter = '';
    answers = [];
    timeLeft = 0;

    currentRound = 1;
    roundScore = 0;
    totalScore = 0;

    _roundFinished = false;
    _gameFinished = false;

    notifyListeners();
  }

  void onNetworkMessage(NetworkMessage message) {
    switch (message.type) {
      case MessageType.startRound:
        currentLetter = message.payload['letter'];
        currentRound = message.payload['round'];
        timeLeft = message.payload['time'];

        answers = settings.categories
            .map((c) => CategoryAnswer(category: c, answer: ''))
            .toList();

        _startTimer();
        notifyListeners();
        break;

      case MessageType.roundResult:
        roundScore = message.payload['roundScore'];
        totalScore = message.payload['totalScore'];

        final list = message.payload['answers'] as List;
        answers = list
            .map(
              (e) => CategoryAnswer(
            category: e['category'],
            answer: e['answer'],
            score: e['score'],
          ),
        )
            .toList();

        _roundFinished = true;
        notifyListeners();
        break;

      case MessageType.endGame:
        _finishGame();
        break;

      default:
        break;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

}
