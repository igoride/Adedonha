import 'dart:math';

class LetterService {
  String randomLetter() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return letters[Random().nextInt(letters.length)];
  }
}