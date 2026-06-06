import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedPostsService {
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference get _ref => FirebaseFirestore.instance
      .collection('users')
      .doc(_uid)
      .collection('saved_posts');

  // Save a post
  static Future<void> savePost(Map<String, dynamic> post) async {
    if (_uid == null) return;
    final docId = post['name'] as String;
    await _ref.doc(docId).set({
      'name': post['name'],
      'type': post['type'],
      'breed': post['breed'],
      'age': post['age'],
      'gender': post['gender'],
      'location': post['location'],
      'description': post['description'],
      'vaccinated': post['vaccinated'],
      'neutered': post['neutered'],
      'savedAt': Timestamp.now(),
    });
  }

  // Remove a saved post
  static Future<void> unsavePost(String name) async {
    if (_uid == null) return;
    await _ref.doc(name).delete();
  }

  // Check if post is saved
  static Future<bool> isSaved(String name) async {
    if (_uid == null) return false;
    final doc = await _ref.doc(name).get();
    return doc.exists;
  }

  // Stream of saved posts
  static Stream<List<Map<String, dynamic>>> savedPostsStream() {
    if (_uid == null) return const Stream.empty();
    return _ref.orderBy('savedAt', descending: true).snapshots().map((s) => s
        .docs
        .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
        .toList());
  }

  // Stream count
  static Stream<int> savedCountStream() {
    if (_uid == null) return Stream.value(0);
    return _ref.snapshots().map((s) => s.docs.length);
  }
}
