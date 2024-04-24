import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
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
  
  bool showPassword = false;
  List<String> licensePlates = [""]; // Initial list of license plates
  TextEditingController plateController = TextEditingController();
  late String first_name;
  late String last_name;
  late String phone;
  late List<String> vehicles;
  late bool isLoading = true;

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

    var url = 'http://10.0.2.2:8000/self/';
    var response = await dio.get(url);

    if (response.statusCode == 200) {
      final userData = response.data;
      isLoading=true;
      setState(() {
        first_name = userData['first_name'].toString() ; // Access 'first_name' with null check
        last_name = userData['last_name'].toString() ;
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.blue,
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the profile screen
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              Text(
                "Edit Profile",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 35,
              ),
              buildTextField("First Name",firstNameController, false,first_name),
              buildTextField("Last Name", lastNameController, false,last_name),
              buildTextField("Phone Number", phoneNumberController, false,phone),
              buildTextField("Old Password",oldPasswordController, true, "********"),
              buildTextField("New Password",newPasswordController, true, "********"),
              SizedBox(height: 10),
              Text(
                "License Plates",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: licensePlates.map((plate) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(plate),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: plateController,
                      decoration: InputDecoration(
                        labelText: "Add License Plate",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      String newPlate = plateController.text.trim();
                      if (newPlate.isNotEmpty) {
                        setState(() {
                          licensePlates.add(newPlate);
                          plateController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 35,
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // Navigate back to the profile screen
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "CANCEL",
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 2.2,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      updateUserProfile(); 
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    child: Text(
                      "SAVE",
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 2.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String labelText,TextEditingController controller,bool isPasswordTextField, String placeholder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        controller: controller,
        obscureText: isPasswordTextField ? showPassword : false,
        decoration: InputDecoration(
          suffixIcon: isPasswordTextField
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.grey,
                  ),
                )
              : null,
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeholder,
          hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
