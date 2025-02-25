import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/menu_screen.dart';
import '../screens/login.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<User?> user = Rx<User?>(null);
  final RxBool isAdmin = false.obs;

  User? get currentUser => user.value;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
    ever(user, _setInitialScreen);
  }

  void _setInitialScreen(User? user) async {
    if (user == null) {
      Get.offAll(() => LoginPage());
    } else {
      await _checkUserRole(user);
    }
  }

  Future<void> _checkUserRole(User user) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        String role = userDoc.get('role') ?? 'user';
        isAdmin.value = (role == 'admin');

        if (isAdmin.value) {
          Get.offAll(() => AdminDashboard());
        } else {
          Get.offAll(() => MenuScreen());
        }
      } else {
        print("No user document found. Creating one...");
        await _createUserDocument(user);
      }
    } catch (e) {
      print("Error fetching user role: $e");
      Get.snackbar("Error", "Error fetching user role: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
      Get.offAll(() => MenuScreen());
    }
  }

  Future<void> _createUserDocument(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'uid': user.uid,
        'role': user.email == 'admin@example.com' ? 'admin' : 'user',
      });
      await _checkUserRole(user);
    } catch (e) {
      print("Error creating user document: $e");
      Get.snackbar("Error", "Error creating user document: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> register(String name, String email, String password,
      {bool isAdmin = false}) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'uid': userCredential.user!.uid,
        'role': isAdmin ? 'admin' : 'user',
      });

      Get.snackbar("Success", "Account created successfully",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      print("Registration Error: $e");
      Get.snackbar("Error", "Registration failed: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      await _checkUserRole(userCredential.user!);
      Get.snackbar("Success", "Logged in successfully",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      print("Login Error: $e");
      Get.snackbar("Error", "Login failed: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      isAdmin.value = false;
      Get.snackbar("Success", "Logged out successfully",
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAll(() => LoginPage());
    } catch (e) {
      print("Logout Error: $e");
      Get.snackbar("Error", "Logout failed: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> createAdminAccount(
      String name, String email, String password) async {
    await register(name, email, password, isAdmin: true);
  }
}
