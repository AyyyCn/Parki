import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/park_booking_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:ionicons/ionicons.dart';


class CustomBottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (int index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
            break;
          case 1:
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ParkBookingScreen()),
            );
            break;
          case 2:
            // Navigate to Ticket
            break;
          case 3:
            // Navigate to Profile
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Ionicons.home_outline),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Ionicons.time_outline),
          label: "Bookings",
        ),
        BottomNavigationBarItem(
          icon: Icon(Ionicons.ticket_outline),
          label: "Ticket",
        ),
        BottomNavigationBarItem(
          icon: Icon(Ionicons.person_outline),
          label: "Profile",
        )
      ],
    );
  }
}
