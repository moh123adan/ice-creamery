import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../screens/adimin/admin_dashboard.dart';
import '../screens/home_screen.dart';
import '../screens/login.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? get currentUser => _user.value;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(auth.currentUser);
    _user.bindStream(auth.userChanges());
    ever(_user, _initialScreen);
  }

  // Handle navigation based on authentication state
  _initialScreen(User? user) async {
    if (user == null) {
      Get.offAll(() => LoginPage());
    } else {
      try {
        DocumentSnapshot userDoc =
        await firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          String role = userDoc['role'] ?? 'user';

          if (role == 'admin') {
            Get.offAll(() => AdminDashboard());
          } else {
            Get.offAll(() => AdminDashboard());
          }
        } else {
          print("No user document found.");
          Get.snackbar("Error", "No user data found in Firestore.",
              backgroundColor: Colors.red, colorText: Colors.white);
          logout(); // ✅ Fixed here (no 'await')
        }
      } catch (e) {
        print("Error fetching user role: $e");
        Get.snackbar("Error", "Error fetching user role: $e",
            backgroundColor: Colors.red, colorText: Colors.white);
        Get.offAll(() => HomePage());
      }
    }
  }

  // Register a new user
  void register(String name, String email, String password) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'uid': userCredential.user!.uid,
        'role': 'user',
      });

      Get.snackbar("Success", "Account created successfully",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      print("Registration Error: $e");
      Get.snackbar("Error", "Registration failed: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // User login
  void login(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      Get.snackbar("Success", "Logged in successfully",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      print("Login Error: $e");
      Get.snackbar("Error", "Login failed: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // User logout
  void logout() async {
    await auth.signOut();
  }
}
