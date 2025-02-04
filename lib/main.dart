import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'controllers/auth_controller.dart';
import 'controllers/admin_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/navigation_controller.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/home_screen.dart';
import 'screens/menu_screen.dart';
import 'firebase_options.dart';
import 'services/firestore_service.dart';
import 'services/image_upload_service.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize services and controllers
    await Get.putAsync(() async => FirestoreService());
    await Get.putAsync(() async => AuthController());
    await Get.putAsync(() async => AdminController());
    await Get.putAsync(() async => ImageUploadService());
    await Get.putAsync(() async => CartController());
    await Get.putAsync(() async => NavigationController());

    // Create admin account if it doesn't exist
    await setupAdminAccount();

    runApp(const IceCreamApp());
  }, (error, stack) {
    print('Uncaught error: $error');
    print(stack);
  });
}

Future<void> setupAdminAccount() async {
  final authController = Get.find<AuthController>();
  final adminEmail = 'admin@example.com';
  final adminPassword = 'adminpassword';

  try {
    // Check if admin account already exists
    // ignore: unused_local_variable
    final userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: adminEmail,
      password: adminPassword,
    );

    // If login successful, admin account exists
    await FirebaseAuth.instance.signOut(); // Sign out immediately
  } catch (e) {
    // If login fails, create admin account
    if (e is FirebaseAuthException && e.code == 'user-not-found') {
      await authController.createAdminAccount(
          'Admin', adminEmail, adminPassword);
    } else {
      print("Error checking admin account: $e");
    }
  }
}

class IceCreamApp extends StatelessWidget {
  const IceCreamApp({Key? key}) : super(key: key);

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
        future: _initializeApp(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            print("Error initializing app: ${snapshot.error}");
            return Scaffold(
              body: Center(child: Text("Error: ${snapshot.error}")),
            );
          } else {
            return _buildAuthenticatedScreen();
          }
        },
      ),
    );
  }

  Future<void> _initializeApp(BuildContext context) async {
    try {
      await precacheImage(const AssetImage("assets/logo.png"), context);
    } catch (e) {
      print("Error loading asset: $e");
    }
  }

  Widget _buildAuthenticatedScreen() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // User is logged in
          final AuthController authController = Get.find<AuthController>();
          return Obx(() {
            if (authController.isAdmin.value) {
              return AdminDashboard();
            } else {
              return MenuScreen();
            }
          });
        } else {
          // User is not logged in
          return const HomePage();
        }
      },
    );
  }
}
