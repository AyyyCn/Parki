import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfileScreen> {
   
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController plateController = TextEditingController();


  
  bool showPassword = false;
  late String first_name;
  late String last_name;
  late String phone;
  late bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchLicensePlates();
  }

   late List<String> licensePlates ; // Initial list of license plates


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
          licensePlates = List<String>.from(responseData['license_plates']);
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

    var url = 'http://10.0.2.2:8000/self/';
    var response = await dio.get(url);

    if (response.statusCode == 200) {
      final userData = response.data;
      setState(() {
        first_name = userData['first_name'].toString() ; // Access 'first_name' with null check
        last_name = userData['last_name'].toString() ;
        phone = userData['phone_number']['national_number'].toString() ; // Access 'phone_number' with null check
        isLoading = false;
      });
    } else {
      print('Failed to fetch user profile');
    }
  } catch (e) {
    print('Error fetching user profile: $e');
  }
}

Future<void> addLicensePlate(String newPlate) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString('sessionId');
      String? csrfToken = prefs.getString('csrfToken');

      var dio = Dio();
      dio.options.headers['Cookie'] = 'sessionid=$sessionId; csrftoken=$csrfToken';
      dio.options.headers['X-CSRFToken'] = csrfToken;

      var url = 'http://10.0.2.2:8000/license_plate';
      if (licensePlates.contains(newPlate))
        print("already exists");
      else{
      var response = await dio.post(url, data: {'license_plate': newPlate});

    }} catch (e) {
      print('Error adding license plate: $e');
    }
  }



Future<void> updateUserProfile() async {
  int c=0;// to make sure 1 alert at a time
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString('sessionId');
      String? csrfToken = prefs.getString('csrfToken');
      if (sessionId == null || csrfToken == null || sessionId.isEmpty || csrfToken.isEmpty) {
      throw Exception('Session ID or CSRF token not found or empty');
    }
    int b=0; //to check whether password is successfully updated or not
    
      var dio = Dio();
      dio.options.headers['Cookie'] = 'sessionid=$sessionId ; csrftoken=$csrfToken';
      dio.options.headers['X-CSRFToken'] = csrfToken;

      var url = 'http://10.0.2.2:8000/self/';
    var response = await dio.get(url);
    if (response.statusCode == 200) {
      var profileData = response.data;
      Map<String, dynamic> passwordData ={};
      var responseData = {};
      if (firstNameController.text.isNotEmpty) {
      profileData['first_name'] = firstNameController.text;
    }
    
    // Check and add last name if valid
    if (lastNameController.text.isNotEmpty) {
      profileData['last_name'] = lastNameController.text;
    }
    // Check and add phone number if valid
    if (phoneNumberController.text.isNotEmpty) {
      profileData['phone_number']['national_number'] = phoneNumberController.text;
   
    //print("phonenumberrrr  : ${phoneNumberController.text}"); 
    }
    
    passwordData={
      'old_password': oldPasswordController.text,
      'new_password' : newPasswordController.text
    };
    print(dio.options.headers);
    print(dio.options.headers['X-CSRFToken']);
    
      var updateProfileresponse = await dio.put(
        url,
        data: profileData,
      );
      print("name/lastname updated");
      var pass = passwordData.toString();
      print("password data : $pass");
      if (oldPasswordController.text.isNotEmpty && newPasswordController.text.isNotEmpty) {
      var url2='http://10.0.2.2:8000/updatepassword';
      try{
      var passwordUpdateResponse = await dio.put(
        url2,
        data: passwordData,
      );
      print("ooooo");
      if ( c==0){
        c=1;
        print("password updated successfully");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Profile updated successfully!'),
              content: Text('Since you changed your password, you have to log in with the new one'),
              actions: [
                TextButton(
                  onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => loginScreen(),
                          ),
                        );                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
      else {
      print("error when updaating password");
      responseData = passwordUpdateResponse.data['error'];
      b=1;
      }}
      catch(e){
        b=1;
        print("error password update") ;
        if(c==0){
          c=1;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed to update profile'),
              content: Text('Make sure old and new passwords are valid'),
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
        );}
        

      };}
      else if (newPasswordController.text.isNotEmpty && c==0){
        b=1;
        c=1;
        print("error password update") ;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed to update profile'),
              content: Text('Old password required! '),
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
      
      print('Response status code: ${updateProfileresponse.statusCode}');
      print('b = ${b}');
      if ((updateProfileresponse.statusCode==200)&&(b==0)&&(c==0)) {
        c=1;
        print('User profile updated successfully');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Profile updated successfully!'),
              content: Text('The changes you have made are saved :) '),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(),
                          ),
                        );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
       
      } else {
        print('Failed to update user profile');
         responseData = updateProfileresponse.data['error'];
        if(c==0){
          c=1;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed to update profile'),
              content: Text(responseData.toString()),
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
        );}
      }
      } 

    } catch (e) {
      print('Error updating user profile: $e');
      print('Failed to update user profile');
      if(c==0){ 
        c=1;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed to update profile'),
              content: Text('something went wrong'),
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
        );}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextField("First Name", firstNameController, false, first_name),
                  buildTextField("Last Name", lastNameController, false, last_name),
                  buildTextField("Phone Number", phoneNumberController, false, phone),
                  buildTextField("Old Password", oldPasswordController, true, "********"),
                  buildTextField("New Password", newPasswordController, true, "********"),
                  SizedBox(height: 20),
                  Text(
                    "License Plates",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: licensePlates.map((plate) {
                      return Chip(
                        label: Text(plate),
                        onDeleted: () {
                          setState(() {
                            licensePlates.remove(plate);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  TextField(
                    controller: plateController,
                    decoration: InputDecoration(
                      labelText: 'Add A New Plate',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      addLicensePlate(value);
                      plateController.clear();
                    },
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: updateUserProfile,
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller, bool isPassword, String placeholder) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !showPassword : false,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: placeholder,
          border: OutlineInputBorder(),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}