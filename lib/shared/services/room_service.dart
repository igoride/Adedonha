import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  Future<String> createRoom(String playerName) async {
    final doc = _db.collection('rooms').doc();

    await doc.set({
      'code': doc.id.substring(0, 6).toUpperCase(),
      'hostId': userId,
      'hostName': playerName,
      'status': 'lobby',
      'roundTime': 120,
      'rounds': 3,
      'categories': {
        'Animal': true,
        'Cidade': true,
        'Objeto': true,
      },
      'currentRoundId': null,
    });

    await addPlayer(doc.id, playerName);
    return doc.id;
  }

  /// Remove o jogador atual da sala, se sala vazia deleta sala
  Future<void> leaveRoom(String roomId) async {
    final roomRef = _db.collection('rooms').doc(roomId);
    final playersRef = roomRef.collection('players');

    await playersRef.doc(userId).delete();

    final remaining = await playersRef.limit(1).get();

    if (remaining.docs.isEmpty) {
      await deleteRoom(roomId, checkHost: false);
    }
  }

  /// Apaga a sala e todas as suas subcoleções (players, rounds,
  Future<void> deleteRoom(String roomId, {bool checkHost = true}) async {
    final roomRef = _db.collection('rooms').doc(roomId);
    final roomSnap = await roomRef.get();

    if (!roomSnap.exists) return;

    if (checkHost && roomSnap.data()?['hostId'] != userId) {
      throw Exception('Apenas o host pode apagar a sala');
    }

    // Apaga rounds e subcoleções
    final roundsSnap = await roomRef.collection('rounds').get();
    for (final roundDoc in roundsSnap.docs) {
      await _deleteSubcollection(roundDoc.reference.collection('answers'));
      await _deleteSubcollection(roundDoc.reference.collection('scores'));
      await roundDoc.reference.delete();
    }

    // apaga os jogadores.
    await _deleteSubcollection(roomRef.collection('players'));

    // apaga o documento da sala.
    await roomRef.delete();
  }

  /// apaga as subcollections
  Future<void> _deleteSubcollection(CollectionReference ref) async {
    const batchSize = 300;

    while (true) {
      final snap = await ref.limit(batchSize).get();
      if (snap.docs.isEmpty) break;

      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (snap.docs.length < batchSize) break;
    }
  }

  Future<String> joinRoom(String code, String playerName) async {
    final snap =
    await _db.collection('rooms').where('code', isEqualTo: code).get();

    if (snap.docs.isEmpty) {
      throw Exception('Sala não encontrada');
    }

    final roomId = snap.docs.first.id;
    await addPlayer(roomId, playerName);
    return roomId;
  }

  Future<void> addPlayer(String roomId, String playerName) async {
    final playersRef =
    _db.collection('rooms').doc(roomId).collection('players');

    final existing = await playersRef
        .where('name', isEqualTo: playerName)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return;

    await playersRef.doc(userId).set({
      'name': playerName,
      'score': 0,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> roomStream(String roomId) {
    return _db
        .collection('rooms')
        .doc(roomId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> playersStream(String roomId) {
    return _db
        .collection('rooms')
        .doc(roomId)
        .collection('players')
        .orderBy('joinedAt')
        .snapshots();
  }

  Future<void> saveSettings(
      String roomId,
      int roundTime,
      int rounds,
      Map<String, bool> categories,
      ) async {
    await _db.collection('rooms').doc(roomId).update({
      'roundTime': roundTime,
      'rounds': rounds,
      'categories': categories,
    });
  }

  Future<Map<String, dynamic>> getRoomSettings(String roomId) async {
    final doc = await _db.collection('rooms').doc(roomId).get();
    final data = doc.data() ?? {};

    return {
      'roundTime': data['roundTime'] ?? 120,
      'rounds': data['rounds'] ?? 3,
      'categories': Map<String, bool>.from(
        data['categories'] ??
            {'Animal': true, 'Cidade': true, 'Objeto': true},
      ),
    };
  }

  Future<bool> isHost(String roomId) async {
    final doc = await _db.collection('rooms').doc(roomId).get();
    return doc['hostId'] == userId;
  }

  Future<void> setRoomStatus(String roomId, String status) async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .update({'status': status});
  }

  Stream<Map<String, dynamic>> settingsStream(String roomId) {
    return _db.collection('rooms').doc(roomId).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return {};

      return {
        'roundTime': data['roundTime'] ?? 120,
        'rounds': data['rounds'] ?? 3,
        'categories': Map<String, bool>.from(
          data['categories'] ??
              {'Animal': true, 'Cidade': true, 'Objeto': true},
        ),
        'hostId': data['hostId'],
        'status': data['status'],
        'code': data['code'],
      };
    });
  }

  Future<DocumentReference> startRound(String roomId) async {
    final roomRef = _db.collection('rooms').doc(roomId);
    final roomSnap = await roomRef.get();

    if (roomSnap['hostId'] != userId) {
      throw Exception('Apenas o host pode iniciar a rodada');
    }

    final settings = await getRoomSettings(roomId);
    final categories = settings['categories'].keys.toList();

    final letter =
    String.fromCharCode(65 + (DateTime.now().millisecondsSinceEpoch % 26));

    final roundRef = await roomRef.collection('rounds').add({
      'letter': letter,
      'startedAt': FieldValue.serverTimestamp(),
      'duration': settings['roundTime'],
      'status': 'playing',
      'categories': categories,
    });

    await roomRef.update({
      'status': 'playing',
      'currentRoundId': roundRef.id,
    });

    return roundRef;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> roundStream(
      String roomId,
      String roundId,
      ) {
    return _db
        .collection('rooms')
        .doc(roomId)
        .collection('rounds')
        .doc(roundId)
        .snapshots();
  }

  Future<void> stopRound(String roomId, String roundId) async {
    final roomRef = _db.collection('rooms').doc(roomId);
    final roomSnap = await roomRef.get();

    if (roomSnap['hostId'] != userId) return;

    await roomRef.update({'status': 'voting'});
    await roomRef
        .collection('rounds')
        .doc(roundId)
        .update({'status': 'voting'});
  }

  Future<void> submitAnswers(
      String roomId,
      String roundId,
      String playerName,
      Map<String, String> answers,
      ) async {
    await _db
        .collection('rooms')
        .doc(roomId)
        .collection('rounds')
        .doc(roundId)
        .collection('answers')
        .doc(userId)
        .set({
      'playerId': userId,
      'playerName': playerName,
      'answers': answers,
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> answersStream(
      String roomId,
      String roundId,
      ) {
    return _db
        .collection('rooms')
        .doc(roomId)
        .collection('rounds')
        .doc(roundId)
        .collection('answers')
        .snapshots();
  }

  Future<void> finishVoting(String roomId) async {
    final roomRef = _db.collection('rooms').doc(roomId);
    final snap = await roomRef.get();

    if (snap['hostId'] != userId) return;

    await roomRef.update({
      'status': 'lobby',
      'currentRoundId': null,
    });
  }

  Future<void> calculateScores(String roomId, String roundId) async {
    final firestore = FirebaseFirestore.instance;

    final roundSnap = await firestore
        .collection('rooms')
        .doc(roomId)
        .collection('rounds')
        .doc(roundId)
        .get();

    final roundLetter =
    roundSnap['letter'].toString().trim().toUpperCase();

    final answersSnap = await firestore
        .collection('rooms')
        .doc(roomId)
        .collection('rounds')
        .doc(roundId)
        .collection('answers')
        .get();

    final Map<String, Map<String, List<String>>> categoryMap = {};

    for (final doc in answersSnap.docs) {
      final data = doc.data();
      final answers = Map<String, dynamic>.from(data['answers'] ?? {});
      final votes = Map<String, dynamic>.from(data['votes'] ?? {});
      final playerId = data['playerId'];

      for (final entry in answers.entries) {
        final category = entry.key;

        final rawAnswer = entry.value.toString().trim();
        final answer = rawAnswer.toUpperCase();

        if (answer.length <= 1) continue;

        if (!answer.startsWith(roundLetter)) continue;

        final yes = votes[category]?['yes'] ?? 0;
        final no = votes[category]?['no'] ?? 0;

        if (no > yes) continue;

        categoryMap.putIfAbsent(category, () => {});
        categoryMap[category]!.putIfAbsent(answer, () => []);
        categoryMap[category]![answer]!.add(playerId);
      }
    }

    final Map<String, int> roundScores = {};

    for (final category in categoryMap.entries) {
      for (final answerEntry in category.value.entries) {
        final players = answerEntry.value;

        final points = players.length == 1 ? 10 : 5;

        for (final uid in players) {
          roundScores[uid] = (roundScores[uid] ?? 0) + points;
        }
      }
    }

    final batch = firestore.batch();

    for (final entry in roundScores.entries) {
      final uid = entry.key;
      final points = entry.value;

      final roundScoreRef = firestore
          .collection('rooms')
          .doc(roomId)
          .collection('rounds')
          .doc(roundId)
          .collection('scores')
          .doc(uid);

      batch.set(roundScoreRef, {
        'points': points,
      });

      final playerRef = firestore
          .collection('rooms')
          .doc(roomId)
          .collection('players')
          .doc(uid);

      batch.update(playerRef, {
        'score': FieldValue.increment(points),
      });
    }

    await batch.commit();
  }

  Future<bool> hasNextRound(String roomId) async {
    final roomRef = _db.collection('rooms').doc(roomId);
    final roomSnap = await roomRef.get();
    final roomData = roomSnap.data()!;

    final totalRounds = roomData['rounds'] ?? 3;
    final playedRounds = (await roomRef.collection('rounds').get()).docs.length;

    return playedRounds < totalRounds;
  }
}




