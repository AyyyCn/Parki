import 'package:flutter/material.dart';
import 'package:frontend/screens/credit_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/park_booking_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/screens/reg_screen.dart';
import 'package:frontend/screens/welcome_screen.dart';
import 'package:frontend/screens/home_screen.dart'; // Import your HomeScreen
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/auth_service.dart'; // Import your AuthService

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

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
      home: FutureBuilder<bool>(
        future: AuthService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show loading indicator while checking auth state
          } else {
            bool isLoggedIn = snapshot.data ?? false;
            return isLoggedIn ? HomePage() : WelcomePage(); // Show HomeScreen if logged in, otherwise show WelcomePage
          }
        },
      ),
      routes: {
        'RegScreen': (context) => RegScreen(),
        '/homepage': (context) => HomePage(),
        '/bookings': (context) => ParkBookingScreen(),
        '/credits': (context) => CreditScreen(),
        '/profile': (context) => ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle unknown routes here
      },
      // Other MaterialApp configurations
    );
  }
}
