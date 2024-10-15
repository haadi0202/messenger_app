import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore (if you're using it for user data)

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? selectedImage;
  String username = ''; // Placeholder for dynamic username
  String email = ''; // Placeholder for dynamic email

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getUserData(); // Fetch user data on initialization
  }

  // Method to fetch user data from Firebase Auth and Firestore
  Future<void> _getUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      setState(() {
        email = user.email ?? ''; // Get the email from Firebase Auth
      });
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();

      setState(() {
        username = userDoc.get('username') ?? 'Unknown'; // Fetch the username
      });
    }
  }

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: Center(
        child: Padding(
        padding: const EdgeInsets.all(80.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture with Edit Button
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.20,
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!) // Show selected image
                      : const AssetImage('assets/avatar.jpg') // Default image
                  as ImageProvider,
                ),
                // Edit button to change profile picture
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: _pickImage, // Opens gallery to pick an image
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Display dynamic username
            Text(
              username,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Display dynamic email
            Text(
              email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    )
    );
  }
}
