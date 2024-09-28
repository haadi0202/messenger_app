//ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger_app/pages/auth/login_or_signup.dart';
import 'package:messenger_app/services/auth.dart';

late Function refreshParent;

class LoginPage extends StatefulWidget {
  LoginPage({super.key, required Function refresh}) {
    refreshParent = refresh;
  }
  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 150),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: 100,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Log In using your email",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    SizedBox(height: 20),
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
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surface,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
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
                        controller: pswdController,
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.lock, color: Colors.grey),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surface, // Whitish surface
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary), // IndigoAccent
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
                    ElevatedButton(
                      onPressed: (emailController.text.isNotEmpty &&
                          pswdController.text.isNotEmpty)
                          ? () async {
                        try {
                          await auth.signIn(
                              email: emailController.text,
                              password: pswdController.text);
                        } on FirebaseAuthException catch (e) {
                          setState(() {
                            errorMessage = e.message;
                          });
                        }
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Log In",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Not a member? ",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onBackground)),
                        GestureDetector(
                          onTap: () {
                            flag = false;
                            refreshParent();
                          },
                          child: Text("Register Now",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary)),
                        ),
                      ],
                    )
                  ],
                ),
              )),
        ));
  }
}