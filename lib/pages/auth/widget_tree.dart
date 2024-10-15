import 'package:flutter/material.dart';
import 'package:messenger_app/pages/auth/login_or_signup.dart';
import 'package:messenger_app/pages/main_page.dart';
import 'package:messenger_app/services/auth.dart';

class WidgetTree extends StatelessWidget {
  final Auth auth = Auth();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: auth.GetAuthStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // When user is logged in, navigate to MainPage with HomePage as the initial page
            return MainPage();
          } else {
            // When user is not logged in, show Login or Signup screen
            return LoginOrSignup();
          }
        });
  }
}
