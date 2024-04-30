import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/edit_profile_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/widgets/custom_bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String name;
  late String phone;
  late List<String> vehicles;
  late bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }
 
  Future<void> fetchUserProfile() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString('sessionId');
    String? csrfToken = prefs.getString('csrfToken');
    print("session id"); 
    print(sessionId);
    print("csrftoken"); 
    print(csrfToken);

    var dio = Dio();
    dio.options.headers['Cookie'] = 'sessionid=$sessionId; csrftoken=$csrfToken';

    var url = 'http://10.0.2.2:8000/self';
    var response = await dio.get(url);

    if (response.statusCode == 200) {
      final userData = response.data;
      print('User Data: $userData'); // Print userData to inspect its structure
      
      setState(() {
        name = userData['first_name'].toString() + " " +userData['last_name'].toString()  ; // Access 'first_name' with null check
        phone = userData['phone_number']['national_number'].toString() ; // Access 'phone_number' with null check
        //vehicles = List<String>.from(userData['vehicles']); // Uncomment and modify if 'vehicles' is an array in the response
        isLoading = false;
      });
    } else {
      print('Failed to fetch user profile');
    }
  } catch (e) {
    print('Error fetching user profile: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 174, 219, 239),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 50),
                  const SizedBox(height: 20),
                  profileItem('Name', name, CupertinoIcons.person),
                  const SizedBox(height: 10),
                  profileItem('Phone', phone, CupertinoIcons.phone),
                  const SizedBox(height: 10),
                  profileItem('Vehicles', ["not loaded yet from db"], Icons.directions_car),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
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
          ),
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
