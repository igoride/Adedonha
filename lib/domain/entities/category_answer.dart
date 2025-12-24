class CategoryAnswer {
  final String category;
  final String answer;
  final int score;

  CategoryAnswer({
    required this.category,
    required this.answer,
    this.score = 0,
  });
}