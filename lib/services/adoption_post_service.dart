import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdoptionPost {
  final String id;
  final String name;
  final String type;
  final String breed;
  final String age;
  final String gender;
  final String location;
  final String description;
  final String contact;
  final bool vaccinated;
  final bool neutered;
  final String postedBy;
  final String postedByName;
  final DateTime createdAt;

  AdoptionPost({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.age,
    required this.gender,
    required this.location,
    required this.description,
    required this.contact,
    required this.vaccinated,
    required this.neutered,
    required this.postedBy,
    required this.postedByName,
    required this.createdAt,
  });

  factory AdoptionPost.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AdoptionPost(
      id: doc.id,
      name: d['name'] ?? '',
      type: d['type'] ?? 'Dog',
      breed: d['breed'] ?? '',
      age: d['age'] ?? '',
      gender: d['gender'] ?? 'Male',
      location: d['location'] ?? '',
      description: d['description'] ?? '',
      contact: d['contact'] ?? '',
      vaccinated: d['vaccinated'] ?? false,
      neutered: d['neutered'] ?? false,
      postedBy: d['postedBy'] ?? '',
      postedByName: d['postedByName'] ?? 'Anonymous',
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
        'breed': breed,
        'age': age,
        'gender': gender,
        'location': location,
        'description': description,
        'contact': contact,
        'vaccinated': vaccinated,
        'neutered': neutered,
        'postedBy': postedBy,
        'postedByName': postedByName,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

class AdoptionPostService {
  static final _col = FirebaseFirestore.instance.collection('adoption_posts');

  // Stream all public posts
  static Stream<List<AdoptionPost>> postsStream() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(AdoptionPost.fromFirestore).toList());
  }

  // Create a new post
  static Future<void> createPost(AdoptionPost post) async {
    await _col.add(post.toMap());
  }

  // Delete own post
  static Future<void> deletePost(String postId) async {
    await _col.doc(postId).delete();
  }

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  static String get _userName =>
      FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous';
  static String? get _uid_ => _uid;
}
