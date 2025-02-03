class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String image;

  ProductModel({required this.id, required this.name, required this.price, required this.description, required this.image});

  // Convert Firestore document into a ProductModel
  factory ProductModel.fromFirestore(Map<String, dynamic> firestoreDoc) {
    return ProductModel(
      id: firestoreDoc['id'],
      name: firestoreDoc['name'],
      price: firestoreDoc['price'],
      description: firestoreDoc['description'],
      image: firestoreDoc['image'],
    );
  }
}
