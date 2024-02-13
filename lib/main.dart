import 'package:flutter/material.dart';
import 'package:ghanuflix/instalayout/profile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Use the old Instagram color scheme for the theme
        primaryColor: Color(0xFF3f729b),
        scaffoldBackgroundColor: Colors.white,
      ),
      home:
      ProfilePage()
      ));
}


