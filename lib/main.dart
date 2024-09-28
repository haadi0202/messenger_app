//ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:messenger_app/pages/auth/widget_tree.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {"/": (context) => WidgetTree()},
      theme: ThemeData(
        // Define the minimalist color scheme with IndigoAccent and whitish tones
        colorScheme: ColorScheme(
          primary: Colors.indigoAccent, // IndigoAccent as the primary color
          primaryContainer: Colors.indigo[100]!, // Lighter indigo variant
          secondary:
          Colors.grey[200]!, // Neutral light color for secondary elements
          secondaryContainer:
          Colors.white, // White for containers and backgrounds
          surface: Colors.white, // Surfaces like cards or dialogs
          background: Colors.grey[50]!, // Light grey background
          error: Colors.redAccent, // Error color
          onPrimary: Colors.white, // Text on IndigoAccent
          onSecondary: Colors.black, // Text on neutral light background
          onSurface: Colors.black, // Text on surface (like card text)
          onBackground: Colors.black, // Text on the app's background
          onError: Colors.white, // Text on error color
          brightness: Brightness.light, // Light theme
        ),
        // Additional theme settings, like text themes and icon themes
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
        ),
        iconTheme: IconThemeData(
          color: Colors
              .indigoAccent, // Icons will have the IndigoAccent color by default
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigoAccent, // App bar background color
          foregroundColor: Colors.white, // Text color in the AppBar
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.indigoAccent, // Default button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}