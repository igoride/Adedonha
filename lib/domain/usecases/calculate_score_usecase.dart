import '../repositories/game_repository.dart';

class CalculateScoreUseCase {
  final GameRepository repository;

  CalculateScoreUseCase(this.repository);

  int call(String answer, String letter) {
    return repository.calculateScore(answer, letter);
  }
}