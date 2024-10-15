import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger_app/pages/auth/login_or_signup.dart';
import 'package:messenger_app/pages/auth/login_page.dart';
import 'package:messenger_app/services/auth.dart';
import 'package:messenger_app/services/firestore_services.dart';

late Function refreshParent;

class SignupPage extends StatefulWidget {
  SignupPage({super.key, required Function refresh}) {
    refreshParent = refresh;
  }

  @override
  State<SignupPage> createState() => SignupPageState();
}

// Signup Page StatefulWidget
class SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? errorMessage = "";

  // Controllers for input fields
  TextEditingController emailController = TextEditingController();
  TextEditingController pswdController = TextEditingController();
  TextEditingController usernameController = TextEditingController();  // Username controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 150),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add, size: 100, color: Theme.of(context).colorScheme.primary),
                SizedBox(height: 30),
                Text("Create Account", style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onBackground)),
                SizedBox(height: 20),

                // Username input
                _buildTextField(
                  controller: usernameController,
                  hintText: "Username",
                  icon: Icons.person,
                ),
                SizedBox(height: 10),

                // Email input
                _buildTextField(
                  controller: emailController,
                  hintText: "example@gmail.com",
                  icon: Icons.email,
                ),
                SizedBox(height: 5),

                // Password input
                _buildTextField(
                  controller: pswdController,
                  hintText: "Password",
                  icon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: 10),

                // Error message display
                if (errorMessage != null && errorMessage!.isNotEmpty)
                  Text(
                    "$errorMessage",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                SizedBox(height: 15),

                // Signup button
                ElevatedButton(
                  onPressed: (emailController.text.isNotEmpty &&
                      pswdController.text.isNotEmpty &&
                      usernameController.text.isNotEmpty)
                      ? () async {
                    try {
                      // Create user with Firebase Authentication using email and password
                      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: pswdController.text.trim(),
                      );

                      // Get the system-generated user ID from FirebaseAuth
                      String userId = userCredential.user!.uid;

                      // Store additional user info in Firestore using addUserInfo from FirestoreServices
                      UsersCollection userCollection = UsersCollection();
                      await userCollection.addUserInfo(
                        userId: userId,
                        userEmail: emailController.text.trim(),
                        userName: usernameController.text.trim(),
                        profilePicture: "assets/avatar.jpg", // Default profile picture path
                      );


    } on FirebaseAuthException catch (e) {
    setState(() {
    errorMessage = e.message;
    });
    }
    }
        : null,
    style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary,
    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    ),
    ),child: Text(
    "Sign Up",
    style: TextStyle(fontSize: 18),
    ),
    ),
    SizedBox(height: 30),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text("Already have an account? ",
    style: TextStyle(
    color: Theme.of(context).colorScheme.onBackground)),
    GestureDetector(
    onTap: () {
    flag = true;
    refreshParent();
    },
    child: Text("LogIn",
    style: TextStyle(fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.primary)))
    ],
    )
    ],
    ),
    )),
    ));
    }

  // Reusable text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2),
        ],
      ),
      child: TextField(
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
