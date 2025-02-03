import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  Future<void> addProduct({
    required String name,
    required double price,
    required String imageUrl,
    required String description,
  }) async {
    try {
      await _productsCollection.add({
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Product added to Firestore successfully");
    } catch (e) {
      print("Error adding product to Firestore: $e");
      rethrow;
    }
  }

  Future<void> testConnection() async {
    try {
      await FirebaseFirestore.instance.collection('test').add({'test': 'data'});
      print("Test write to Firestore successful");
    } catch (e) {
      print("Error writing to Firestore: $e");
      rethrow;
    }
  }
}
