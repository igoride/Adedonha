import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser!.uid;

  // ===================== ROOMS =====================

  Future<String> createRoom(String name) async {
    final code = _generateCode();

    final room = await _db.collection('rooms').add({
      'code': code,
      'status': 'waiting',
      'currentLetter': '',
      'createdAt': FieldValue.serverTimestamp(),
      'settings': {
        'roundTime': 120,
        'rounds': 3,
        'categories': {
          'animal': true,
          'cidade': true,
          'objeto': true,
        }
      }
    });

    await _addPlayer(room.id, name);
    return room.id;
  }

  Future<String> joinRoom(String code, String name) async {
    final query = await _db
        .collection('rooms')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Sala não encontrada');
    }

    final roomId = query.docs.first.id;
    await _addPlayer(roomId, name);
    return roomId;
  }

  Future<void> _addPlayer(String roomId, String name) async {
    await _db
        .collection('rooms')
        .doc(roomId)
        .collection('players')
        .doc(userId)
        .set({
      'name': name,
      'score': 0,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  // ===================== SETTINGS =====================

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
        .map((doc) =>
    Map<String, dynamic>.from(doc.data()!['settings']));
  }

  // ===================== GAME =====================

  Future<void> setLetter(String roomId, String letter) async {
    await _db.collection('rooms').doc(roomId).update({
      'currentLetter': letter,
    });
  }

  Stream<String> letterStream(String roomId) {
    return _db
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .map((doc) => doc['currentLetter'] ?? '');
  }

  Future<void> updateRoomStatus(
      String roomId, {
        required String status,
      }) async {
    await _db.collection('rooms').doc(roomId).update({
      'status': status,
    });
  }

  // ===================== STREAMS =====================

  Stream<DocumentSnapshot> roomStream(String roomId) {
    return _db.collection('rooms').doc(roomId).snapshots();
  }

  Stream<QuerySnapshot> playersStream(String roomId) {
    return _db
        .collection('rooms')
        .doc(roomId)
        .collection('players')
        .snapshots();
  }

  // ===================== UTILS =====================

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
        4,
            (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
  }
}



