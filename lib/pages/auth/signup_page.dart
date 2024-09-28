//ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger_app/pages/auth/login_or_signup.dart';
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

class SignupPageState extends State<SignupPage> {
  Auth auth = Auth();
  String? errorMessage = "";
  //email controller
  TextEditingController emailController = TextEditingController();
  //pswd controller
  TextEditingController pswdController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical:150),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add, size: 100,
                      color: Theme.of(context).colorScheme.primary,),
                    SizedBox(height: 30),

                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 16,

                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    SizedBox(height: 20),

                    //email input
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: TextField(
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "example@gmail.com",
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.email, color: Colors.grey),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),

                    //password
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],

                      ),child: TextField(
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                      },
                      controller: pswdController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.lock, color: Colors.grey),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                    ),
                    SizedBox(height: 10),
                    // Error Message Display
                    if (errorMessage != null && errorMessage!.isNotEmpty)
                      Text(
                        "$errorMessage",
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    SizedBox(height: 15),
                    //signup button
                    ElevatedButton(
                      onPressed: (emailController.text.isNotEmpty &&
                          pswdController.text.isNotEmpty)
                          ? () async {
                        print("in system request");
                        try {
                          await auth.createUser(
                            email: emailController.text,
                            password: pswdController.text,
                          );
                          // Extra functionality (add user email to UserCollection)
                          UsersCollection usersCollection = UsersCollection();
                          String userName = emailController.text;
                          int index = userName.indexOf("@");
                          userName = userName.substring(0, index);
                          usersCollection.addUserEmail(userEmail: userName);
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
}