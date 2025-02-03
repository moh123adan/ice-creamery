class OrderModel {
  final String id;
  final String username;       // ✅ Added
  final String productName;    // ✅ Added
  final int quantity;

  OrderModel({
    required this.id,
    required this.username,
    required this.productName,
    required this.quantity,
  });

  // ✅ Factory constructor to create an OrderModel from Firestore
  factory OrderModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return OrderModel(
      id: documentId,
      username: data['username'] ?? '',       // Fallback if null
      productName: data['productName'] ?? '', // Fallback if null
      quantity: data['quantity'] ?? 0,
    );
  }

  // ✅ Convert to Map (useful when adding/updating Firestore documents)
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'productName': productName,
      'quantity': quantity,
    };
  }
}
