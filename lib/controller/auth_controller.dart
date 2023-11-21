import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app/view/bottom_nav_bar/bottom_bar_view.dart';
import 'package:event_management_app/view/home_screen.dart';
import 'package:event_management_app/view/profile/add_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:path/path.dart' as Path;

class AuthController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;

  var isLoading = false.obs;

  void login({required String email, required String password}) {
    isLoading(true);
    auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      isLoading(false);
      Get.to(() => BottomBarView());
    }).catchError((e) {
      isLoading(false);
      Get.snackbar("Warning", e.toString());
    });
  }

  void signUp(String email, String password) {
    isLoading(true);
    auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      isLoading(false);
      Get.to(() => AdProfileScreen());
    }).catchError((e) {
      isLoading(false);
      Get.snackbar("Warning", e.toString());
    });
  }

  void forgotPassword(String email) {
    auth.sendPasswordResetEmail(email: email).then((value) {
      Get.back();
      Get.snackbar(
          "Email Sent", "Email sent at your address for password resetting ");
    }).catchError((e) {
      Get.snackbar("Failed", "Facing following Problem :" + e.toString());
    });
  }

  signInWithGoogle() async {
    isLoading(true);
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      isLoading(false);
      Get.to(HomeScreen());
    }).catchError((e) {
      isLoading(false);
      Get.snackbar("Error", e.toString());
    });
  }

  var isProfileInformationLoading = false.obs;
  Future<String> uploadImageToFirebaseStorage(File image) async {
    String ImageUrl = '';
    String fileName = Path.basename(image.path);

    var ref = FirebaseStorage.instance.ref().child('profileImages/$fileName');
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref
        .getDownloadURL()
        .then((value) => ImageUrl = value)
        .catchError((e) {});
    return ImageUrl;
  }

  uploadFileData(String imageUrl, String firstName, String lastName,
      String mobileNumber, String dob, String gender) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection("users").doc(uid).set({
      'imageUrl': imageUrl,
      'firstName': firstName,
      'lastName': lastName,
      'mobileNumber': mobileNumber,
      'dob': dob,
      'gender': gender
    }).then((value) {
      isProfileInformationLoading(false);
      Get.offAll(() => BottomBarView());
    });
  }
}
