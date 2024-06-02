import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/auth_service.dart';
import 'package:frontend/screens/edit_profile_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/widgets/custom_bottom_navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String name;
  late String phone;
  late List<String> vehicles = ["Loading ..."];
  late bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchLicensePlates();
  }

  Future<void> fetchLicensePlates() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString('sessionId');
      String? csrfToken = prefs.getString('csrfToken');

      var dio = Dio();
      dio.options.headers['Cookie'] = 'sessionid=$sessionId; csrftoken=$csrfToken';
      dio.options.headers['X-CSRFToken'] = csrfToken;

      var url = 'http://10.0.2.2:8000/license_plate';
      var response = await dio.get(url);

      if (response.statusCode == 200) {
        var responseData = response.data;
        print('Response data: $responseData');

        if (responseData is Map && responseData.containsKey('license_plates')) {
          setState(() {
            vehicles = List<String>.from(responseData['license_plates']);
          });
        } else {
          print('License plates data is not in the expected format');
        }
      } else {
        print('Failed to fetch license plates');
      }
    } catch (e) {
      print('Error fetching license plates: $e');
    }
  }

  Future<void> logOutUser() async {
    setState(() {
      isLoading = true;
    });
    var dio = Dio();
    var url = 'http://10.0.2.2:8000/logoutAPI';

    try {
      var response = await dio.post(
        url,
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => loginScreen()),
        );
        String cookieHeader = response.headers['set-cookie'].toString();
        print(cookieHeader);
        // Clear session-related data from SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('sessionId');
        await prefs.remove('csrfToken');
        // Update isLoggedIn status to false
        AuthService.logout();
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Logout Failed'),
              content: Text('Try again later'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle unexpected errors
      print('Error: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An unexpected error occurred.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString('sessionId');
      String? csrfToken = prefs.getString('csrfToken');
      var dio = Dio();
      dio.options.headers['Cookie'] = 'sessionid=$sessionId; csrftoken=$csrfToken';

      var url = 'http://10.0.2.2:8000/self';
      var response = await dio.get(url);

      if (response.statusCode == 200) {
        final userData = response.data;
        print('User Data: $userData'); // Print userData to inspect its structure

        setState(() {
          name = userData['first_name'].toString() + " " + userData['last_name'].toString(); // Access 'first_name' with null check
          phone = userData['phone_number']['national_number'].toString(); // Access 'phone_number' with null check
          //vehicles = List<String>.from(userData['vehicles']); // Uncomment and modify if 'vehicles' is an array in the response
          isLoading = false;
        });
      } else {
        print('Failed to fetch user profile');
        setState(() {
          isLoading = false; // Error occurred, set isLoading to false
        });
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      setState(() {
        isLoading = false; // Exception occurred, set isLoading to false
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.purple, // Set app bar color to purple
          title: Text(
            'Your Profile',
            style: TextStyle(color: Colors.white), // Set text color to white
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle),
              color: Colors.white,
              onPressed: () {}
                
            ),
          ],
          floating: true,
          elevation: 0,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      profileItem('Name', name, CupertinoIcons.person),
                      const SizedBox(height: 10),
                      profileItem('Phone', phone, CupertinoIcons.phone),
                      const SizedBox(height: 10),
                      profileItem('Vehicles', vehicles, Icons.directions_car),
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
                            backgroundColor: Color.fromARGB(255, 216, 219, 234),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Edit Profile',
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Show alert to make sure user really wants to log out
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Log Out'),
                                  content: Text('You\'re about to log out. Continue?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        logOutUser();
                                      },
                                      child: Text('Continue'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(15),
                            backgroundColor: Color.fromARGB(255, 241, 209, 207),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Sign Out',
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: CustomBottomNavigationBar(),
  );
}


  Widget profileItem(String title, dynamic data, IconData iconData) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: Colors.black.withOpacity(.2),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: _buildSubtitle(data),
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(iconData, color: Colors.black),
        ),
        tileColor: Colors.white,
      ),
    );
  }

  Widget _buildSubtitle(dynamic data) {
    if (data is List<String>) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.map((licensePlate) => Text(
          licensePlate,
          style: GoogleFonts.lato(fontSize: 16),
        )).toList(),
      );
    } else {
      return Text(
        data.toString(),
        style: GoogleFonts.lato(fontSize: 16),
      );
    }
  }
}
