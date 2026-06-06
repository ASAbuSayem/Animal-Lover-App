import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Pet {
  final String id;
  final String name;
  final String type;
  final String breed;
  final int age;
  final double weight;
  final String? vaccineDate;
  final String? mealTime;
  final String? notes;
  final DateTime createdAt;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.age,
    required this.weight,
    this.vaccineDate,
    this.mealTime,
    this.notes,
    required this.createdAt,
  });

  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Pet(
      id: doc.id,
      name: d['name'] ?? '',
      type: d['type'] ?? 'Dog',
      breed: d['breed'] ?? '',
      age: d['age'] ?? 1,
      weight: (d['weight'] ?? 0).toDouble(),
      vaccineDate: d['vaccineDate'],
      mealTime: d['mealTime'],
      notes: d['notes'],
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
        'breed': breed,
        'age': age,
        'weight': weight,
        'vaccineDate': vaccineDate,
        'mealTime': mealTime,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

class PetService {
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference get _petsRef => FirebaseFirestore.instance
      .collection('users')
      .doc(_uid)
      .collection('pets');

  // Stream of pets (real-time)
  static Stream<List<Pet>> petsStream() {
    if (_uid == null) return const Stream.empty();
    return _petsRef
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(Pet.fromFirestore).toList());
  }

  // Add pet
  static Future<void> addPet(Pet pet) async {
    if (_uid == null) return;
    await _petsRef.add(pet.toMap());
  }

  // Delete pet
  static Future<void> deletePet(String petId) async {
    if (_uid == null) return;
    await _petsRef.doc(petId).delete();
  }
}
