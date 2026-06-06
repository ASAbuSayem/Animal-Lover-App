import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdoptionRequest {
  final String id;
  final String postId;
  final String petName;
  final String petType;
  final String requesterId;
  final String requesterName;
  final String requesterContact;
  final String ownerId;
  final String status;
  final DateTime createdAt;

  AdoptionRequest({
    required this.id,
    required this.postId,
    required this.petName,
    required this.petType,
    required this.requesterId,
    required this.requesterName,
    required this.requesterContact,
    required this.ownerId,
    required this.status,
    required this.createdAt,
  });

  factory AdoptionRequest.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AdoptionRequest(
      id: doc.id,
      postId: d['postId'] ?? '',
      petName: d['petName'] ?? '',
      petType: d['petType'] ?? '',
      requesterId: d['requesterId'] ?? '',
      requesterName: d['requesterName'] ?? '',
      requesterContact: d['requesterContact'] ?? '',
      ownerId: d['ownerId'] ?? '',
      status: d['status'] ?? 'pending',
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }
}

class AdoptionRequestService {
  static final _col =
      FirebaseFirestore.instance.collection('adoption_requests');

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  static String get _name =>
      FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous';

  // Send adoption request
  static Future<void> sendRequest({
    required String postId,
    required String petName,
    required String petType,
    required String ownerId,
    required String contact,
  }) async {
    if (_uid == null) return;

    // Check if already requested
    final existing = await _col
        .where('postId', isEqualTo: postId)
        .where('requesterId', isEqualTo: _uid)
        .get();
    if (existing.docs.isNotEmpty) return;

    await _col.add({
      'postId': postId,
      'petName': petName,
      'petType': petType,
      'requesterId': _uid,
      'requesterName': _name,
      'requesterContact': contact,
      'ownerId': ownerId,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });
  }

  // Check if user already sent request for this post
  static Future<bool> hasRequested(String postId) async {
    if (_uid == null) return false;
    final snap = await _col
        .where('postId', isEqualTo: postId)
        .where('requesterId', isEqualTo: _uid)
        .get();
    return snap.docs.isNotEmpty;
  }

  // ── Stream incoming requests — NO compound index needed ──
  static Stream<List<AdoptionRequest>> incomingRequestsStream() {
    if (_uid == null) return const Stream.empty();
    return _col.where('ownerId', isEqualTo: _uid).snapshots().map((s) => s.docs
        .map(AdoptionRequest.fromFirestore)
        .where((r) => r.status == 'pending')
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  // Accept request
  static Future<void> acceptRequest(String requestId) async {
    await _col.doc(requestId).update({'status': 'accepted'});
  }

  // Reject request
  static Future<void> rejectRequest(String requestId) async {
    await _col.doc(requestId).update({'status': 'rejected'});
  }

  // ── Count pending — NO compound index needed ──
  static Stream<int> pendingCountStream() {
    if (_uid == null) return Stream.value(0);
    return _col.where('ownerId', isEqualTo: _uid).snapshots().map((s) => s.docs
        .map(AdoptionRequest.fromFirestore)
        .where((r) => r.status == 'pending')
        .length);
  }
}
