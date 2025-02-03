import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for products
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  // Collection reference for images
  final CollectionReference _imagesCollection =
      FirebaseFirestore.instance.collection('images');

  Future<void> addProduct({
    required String name,
    required double price,
    String? imageUrl,
    required String description,
  }) async {
    try {
      final productData = {
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      };

      print('Attempting to add product with data: $productData');

      final docRef = await _productsCollection.add(productData);

      print('Product added successfully with ID: ${docRef.id}');

      // If an image URL is provided, save it to the images collection as well
      if (imageUrl != null) {
        await saveImageUrlToFirebase(imageUrl);
      }
    } catch (e, stackTrace) {
      print('Error adding product to Firestore: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> saveImageUrlToFirebase(String imageUrl) async {
    try {
      await _imagesCollection.add({
        'url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Image URL saved to Firebase');
    } catch (e) {
      print('Error saving image URL to Firebase: $e');
      rethrow;
    }
  }

  // Test method to verify Firestore connection
  Future<bool> testFirestoreConnection() async {
    try {
      await _firestore.collection('test').add({
        'timestamp': FieldValue.serverTimestamp(),
        'test': true,
      });
      print('Firestore connection test successful');
      return true;
    } catch (e) {
      print('Firestore connection test failed: $e');
      return false;
    }
  }

  // Method to get all products
  Stream<QuerySnapshot> getProducts() {
    return _productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Method to get all image URLs
  Stream<QuerySnapshot> getImageUrls() {
    return _imagesCollection.orderBy('timestamp', descending: true).snapshots();
  }

  getOrders() {}
}
