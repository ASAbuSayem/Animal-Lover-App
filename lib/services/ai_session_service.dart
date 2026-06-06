import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiSessionService {
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference get _ref => FirebaseFirestore.instance
      .collection('users')
      .doc(_uid)
      .collection('ai_sessions');

  // Save a session after AI analysis
  static Future<void> saveSession({
    required String type, // 'symptom' or 'care'
    required String petName,
    String? petType,
    int? riskScore,
    String? riskLevel,
  }) async {
    if (_uid == null) return;
    await _ref.add({
      'type': type,
      'petName': petName,
      'petType': petType ?? '',
      'riskScore': riskScore,
      'riskLevel': riskLevel ?? '',
      'createdAt': Timestamp.now(),
    });
  }

  // Stream session count
  static Stream<int> sessionCountStream() {
    if (_uid == null) return Stream.value(0);
    return _ref.snapshots().map((s) => s.docs.length);
  }

  // Stream all sessions
  static Stream<List<Map<String, dynamic>>> sessionsStream() {
    if (_uid == null) return const Stream.empty();
    return _ref.orderBy('createdAt', descending: true).snapshots().map((s) => s
        .docs
        .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
        .toList());
  }
}
