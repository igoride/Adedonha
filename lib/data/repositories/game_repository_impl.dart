
import 'package:adedonha/data/services/letter_service.dart';
import 'package:adedonha/domain/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository{
  final LetterService service;
  
  GameRepositoryImpl(this.service);

  @override
  String generateLetter() {
    return service.randomLetter();
  }

  @override
  int calculateScore(String answer, String letter) {
    if (answer.isEmpty) return 0;
    if (answer.toUpperCase().startsWith(letter)) return 10;
    return 0;
  }

}