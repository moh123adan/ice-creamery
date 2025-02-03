import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'controllers/auth_controller.dart';
import 'controllers/admin_controller.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';
import 'services/firestore_service.dart';
import 'services/image_upload_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize services and controllers
  Get.put(FirestoreService());
  Get.put(AuthController());
  Get.put(AdminController());
  Get.put(ImageUploadService());

  runApp(const IceCreamApp());
}

class IceCreamApp extends StatelessWidget {
  const IceCreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ice Cream App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: precacheImage(const AssetImage("assets/logo.png"), context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            print("Error loading asset: ${snapshot.error}");
            return const Scaffold(
              body: Center(child: Text("Error loading assets")),
            );
          } else {
            return const HomePage();
          }
        },
      ),
    );
  }
}

class ImageUploadScreen extends StatelessWidget {
  ImageUploadScreen({Key? key}) : super(key: key);

  final ImagePicker _picker = ImagePicker();
  final ImageUploadService _imageUploadService = Get.find<ImageUploadService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  Future<void> _uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final File imageFile = File(image.path);
      final String? imageUrl =
          await _imageUploadService.uploadImageToImgBB(imageFile);
      if (imageUrl != null) {
        await _firestoreService.saveImageUrlToFirebase(imageUrl);
        Get.snackbar('Success', 'Image uploaded and saved successfully');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Upload')),
      body: Center(
        child: ElevatedButton(
          onPressed: _uploadImage,
          child: const Text('Upload Image'),
        ),
      ),
    );
  }
}
