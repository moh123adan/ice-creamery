import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/admin_controller.dart';
// import '../controllers/admin_controller.dart';

class AdminDashboard extends StatelessWidget {
  AdminDashboard({super.key});

  final AdminController _adminController = Get.find<AdminController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final Rx<XFile?> selectedImage = Rx<XFile?>(null);

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = pickedFile;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 10),
              Obx(() {
                if (selectedImage.value == null) {
                  return const Text('No Image Selected');
                } else {
                  return kIsWeb
                      ? Image.network(selectedImage.value!.path, height: 150)
                      : Image.file(File(selectedImage.value!.path),
                          height: 150);
                }
              }),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Select Image'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      priceController.text.isEmpty ||
                      descriptionController.text.isEmpty ||
                      selectedImage.value == null) {
                    Get.snackbar("Error",
                        "All fields are required and an image must be selected.");
                    return;
                  }

                  try {
                    final imageFile = File(selectedImage.value!.path);
                    final imageUrl =
                        await _adminController.uploadImage(imageFile);

                    await _adminController.addNewProduct(
                      nameController.text,
                      double.parse(priceController.text),
                      imageUrl,
                      descriptionController.text,
                    );

                    // Clear fields after successful upload
                    nameController.clear();
                    priceController.clear();
                    descriptionController.clear();
                    selectedImage.value = null;

                    Get.snackbar("Success", "Product added successfully!");
                  } catch (e) {
                    print('Error occurred: $e');
                    Get.snackbar("Error", "Failed to add product: $e");
                  }
                },
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
