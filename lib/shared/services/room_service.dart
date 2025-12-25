import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _playerName;

  String get uid => _auth.currentUser!.uid;

  Future<void> saveSettings(
      String roomId, {
        required int roundTime,
        required int rounds,
        required Map<String, bool> categories,
      }) async {
    await _db.collection('rooms').doc(roomId).update({
      'settings': {
        'roundTime': roundTime,
        'rounds': rounds,
        'categories': categories,
      }
    });
  }

  Stream<Map<String, dynamic>> settingsStream(String roomId) {
    return _db
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .map((doc) {
      final data = doc.data()!;
      return Map<String, dynamic>.from(data['settings'] ?? {});
    });
  }
  
  /* =========================
     PLAYER
  ========================== */

  Future<void> setPlayerName(String name) async {
    _playerName = name.trim();
  }

  /* =========================
     ROOM
  ========================== */

  Future<String> createRoom() async {
    if (_playerName == null || _playerName!.isEmpty) {
      throw Exception('Nome do jogador não definido');
    }

    final roomRef = _db.collection('rooms').doc();
    final code = roomRef.id.substring(0, 4).toUpperCase();

    await roomRef.set({
      'code': code,
      'status': 'waiting',
      'currentLetter': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await roomRef
        .collection('players')
        .doc(uid)
        .set({
      'name': _playerName,
      'score': 0,
      'joinedAt': FieldValue.serverTimestamp(),
    });

    return roomRef.id;
  }

  Future<String> joinRoom(String code) async {
    if (_playerName == null || _playerName!.isEmpty) {
      throw Exception('Nome do jogador não definido');
    }

    final query = await _db
        .collection('rooms')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Sala não encontrada');
    }

    final roomRef = query.docs.first.reference;

    await roomRef.collection('players').doc(uid).set({
      'name': _playerName,
      'score': 0,
      'joinedAt': FieldValue.serverTimestamp(),
    });

    return roomRef.id;
  }

  /* =========================
     GAME FLOW
  ========================== */

  Future<void> startGame(String roomId) async {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final letter = letters[Random().nextInt(letters.length)];

    await _db.collection('rooms').doc(roomId).update({
      'status': 'playing',
      'currentLetter': letter,
      'startedAt': FieldValue.serverTimestamp(),
      'stopBy': null,
    });
  }

  Future<void> stopGame(String roomId) async {
    await _db.collection('rooms').doc(roomId).update({
      'status': 'finished',
      'stopBy': uid,
    });
  }

  Future<void> submitAnswers(
      String roomId,
      Map<String, String> answers,
      ) async {
    await _db
        .collection('rooms')
        .doc(roomId)
        .collection('players')
        .doc(uid)
        .set({
      'answers': answers,
    }, SetOptions(merge: true));
  }

  Future<void> calculateScores(String roomId) async {
    final playersSnap = await _db
        .collection('rooms')
        .doc(roomId)
        .collection('players')
        .get();

    final Map<String, Map<String, int>> occurrences = {};

    for (var p in playersSnap.docs) {
      final answers = Map<String, dynamic>.from(p['answers'] ?? {});
      answers.forEach((cat, value) {
        final v = value.toString().toLowerCase().trim();
        if (v.isEmpty) return;

        occurrences.putIfAbsent(cat, () => {});
        occurrences[cat]![v] =
            (occurrences[cat]![v] ?? 0) + 1;
      });
    }

    for (var p in playersSnap.docs) {
      int score = 0;
      final answers = Map<String, dynamic>.from(p['answers'] ?? {});

      answers.forEach((cat, value) {
        final v = value.toString().toLowerCase().trim();
        if (v.isEmpty) return;

        score += occurrences[cat]![v]! > 1 ? 5 : 10;
      });

      await p.reference.update({'score': score});
    }
  }

  /* =========================
     STREAMS
  ========================== */

  Stream<DocumentSnapshot> roomStream(String roomId) =>
      _db.collection('rooms').doc(roomId).snapshots();

  Stream<QuerySnapshot> playersStream(String roomId) =>
      _db
          .collection('rooms')
          .doc(roomId)
          .collection('players')
          .snapshots();
}


