// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/firestore_service.dart';
import '../models/product.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final String _imgbbApiKey =
      '45a7b0069a5542187628a448ca0ea525'; // Your ImgBB API key

  RxList<Product> products = <Product>[].obs;
  RxList<UserModel> users = <UserModel>[].obs;
  RxList<OrderModel> orders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchUsers();
    fetchOrders();
  }

  Future<void> fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      products.value = snapshot.docs
          .map((doc) =>
              Product.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching products: $e');
      Get.snackbar('Error', 'Failed to fetch products');
    }
  }

  Future<void> fetchUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      users.value = snapshot.docs
          .map((doc) =>
              UserModel.fromMap(doc.data(), doc.id)).cast<UserModel>()
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      Get.snackbar('Error', 'Failed to fetch users');
    }
  }

  Future<void> fetchOrders() async {
    try {
      final snapshot = await _firestore.collection('orders').get();
      orders.value = snapshot.docs
          .map((doc) =>
              OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching orders: $e');
      Get.snackbar('Error', 'Failed to fetch orders');
    }
  }

  Future<String> uploadImage(Uint8List imageData) async {
    try {
      final uri = Uri.parse('https://api.imgbb.com/1/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['key'] = _imgbbApiKey
        ..files.add(http.MultipartFile.fromBytes(
          'image',
          imageData,
          filename: 'image.jpg',
        ));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonData = json.decode(responseString);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        final imageUrl = jsonData['data']['url'];
        print('Image uploaded successfully to ImgBB. URL: $imageUrl');
        return imageUrl;
      } else {
        throw Exception('Failed to upload image to ImgBB');
      }
    } catch (e) {
      print('Error uploading image to ImgBB: $e');
      rethrow;
    }
  }

  Future<void> addNewProduct(
      String name, double price, String imageUrl, String description) async {
    try {
      await _firestoreService.addProduct(
        name: name,
        price: price,
        imageUrl: imageUrl,
        description: description,
      );
      await fetchProducts(); // Refresh the products list
      print('Product added successfully');
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(String id, String name, double price,
      String imageUrl, String description) async {
    try {
      await _firestore.collection('products').doc(id).update({
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'description': description,
      });
      await fetchProducts(); // Refresh the products list
    } catch (e) {
      print('Error updating product: $e');
      throw 'Failed to update product';
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
      await fetchProducts(); // Refresh the products list
    } catch (e) {
      print('Error deleting product: $e');
      throw 'Failed to delete product';
    }
  }

  Future<void> updateUserRole(String id, bool isAdmin) async {
    try {
      await _firestore.collection('users').doc(id).update({
        'role': isAdmin ? 'admin' : 'user',
      });
      await fetchUsers(); // Refresh the users list
    } catch (e) {
      print('Error updating user role: $e');
      throw 'Failed to update user role';
    }
  }
}
