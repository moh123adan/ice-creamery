// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/firestore_service.dart';

class AdminController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final String _imgbbApiKey =
      '45a7b0069a5542187628a448ca0ea525'; // Your ImgBB API key

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
      print('Product added successfully');
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }
}
