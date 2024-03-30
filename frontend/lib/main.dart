import 'package:flutter/material.dart';
import 'package:frontend/screens/reg_screen.dart';
import 'package:frontend/screens/welcome_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parki',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.mulishTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: WelcomePage(),
      routes: {
      'RegScreen': (context) => RegScreen(),
      // Other routes if any
     },
    onGenerateRoute: (settings) {
    // Handle unknown routes here
    },
    // Other MaterialApp configurations
     );
  }
}