import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/edit_profile_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/widgets/custom_bottom_navigation_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 174, 219, 239), 
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),
            
            const SizedBox(height: 20),
            profileItem('Name', 'Jalila', CupertinoIcons.person),
            const SizedBox(height: 10),
            profileItem('Phone', '02523368', CupertinoIcons.phone),
            const SizedBox(height: 10),
            profileItem('Vehicles', ['ABC123', 'DEF456','546154','GG45T'], Icons.directions_car),
            const SizedBox(height: 20),
           SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to the profile edit page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(15),
            ),
            child: const Text('Edit Profile'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // sign out
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => loginScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(15),
            ),
            child: const Text('Sign Out'),
          ),
        ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  Widget profileItem(String title, dynamic data, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: Colors.deepOrange.withOpacity(.2),
            spreadRadius: 2,
            blurRadius: 10,
          )
        ],
      ),
      child: ListTile(
        title: Text(title),
        subtitle: _buildSubtitle(data),
        leading: Icon(iconData),
        tileColor: Colors.white,
      ),
    );
  }

  // Widget for displaying profile information dynamically based on the data type
  Widget _buildSubtitle(dynamic data) {
    if (data is List<String>) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.map((licensePlate) => Text(licensePlate)).toList(),
      );
    } else {
      return Text(data.toString());
    }
  }
}
