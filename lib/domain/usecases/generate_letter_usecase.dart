import '../repositories/game_repository.dart';

class GenerateLetterUseCase {
  final GameRepository repository;

  GenerateLetterUseCase(this.repository);

  String call() {
    return repository.generateLetter();
  }
}