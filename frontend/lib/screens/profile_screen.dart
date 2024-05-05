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
  late bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
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
    // reset session ID and CSRF token to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sessionId', '');
    await prefs.setString('csrfToken', '');
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
        name = userData['first_name'].toString() + " " +userData['last_name'].toString()  ; // Access 'first_name' with null check
        phone = userData['phone_number']['national_number'].toString() ; // Access 'phone_number' with null check
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
