import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  @override
  _CustomBottomNavigationBarState createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0; // Initialize with the default index
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Listen for route changes
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _updateSelectedIndex(ModalRoute.of(context)?.settings.name);
    });
  }

  void _updateSelectedIndex(String? routeName) {
    if (routeName != null) {
      setState(() {
        _selectedIndex = _getSelectedIndex(routeName);
      });
    }
  }

  int _getSelectedIndex(String routeName) {
    switch (routeName) {
      case '/homepage':
        return 0;
      case '/bookings':
        return 1;
      case '/credits':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Ionicons.home_outline),
          activeIcon: Icon(Ionicons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Ionicons.time_outline),
          activeIcon: Icon(Ionicons.time),
          label: "Bookings",
        ),
        BottomNavigationBarItem(
          icon: Icon(Ionicons.ticket_outline),
          activeIcon: Icon(Ionicons.ticket),
          label: "Ticket",
        ),
        BottomNavigationBarItem(
          icon: Icon(Ionicons.person_outline),
          activeIcon: Icon(Ionicons.person),
          label: "Profile",
        ),
      ],
    );
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 0:
          _navigateTo(context, '/homepage');
          break;
        case 1:
          _navigateTo(context, '/bookings');
          break;
        case 2:
          _navigateTo(context, '/credits');
          break;
        case 3:
          _navigateTo(context, '/profile');
          break;
      }
    }
  }
  void _navigateTo(BuildContext context, String routeName) {
    Navigator.of(context).pushReplacementNamed(routeName);
  }
}
