import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  final List<String> _categories = [
    'Name',
    'Animal',
    'City',
    'Object',
    'Food',
  ];

  int _timePerRound = 60;

  int _totalRounds = 3;

  int get totalRounds => _totalRounds;

  List<String> get categories => List.unmodifiable(_categories);
  int get timePerRound => _timePerRound;

  void setTotalRounds(int value) {
    if (value < 1) return;
    _totalRounds = value;
    notifyListeners();
  }

  void addCategory(String category) {
    if (category.trim().isEmpty) return;
    _categories.add(category.trim());
    notifyListeners();
  }

  void removeCategory(int index) {
    _categories.removeAt(index);
    notifyListeners();
  }

  void setTimePerRound(int seconds) {
    _timePerRound = seconds;
    notifyListeners();
  }
}

