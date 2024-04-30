import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/phone_verif_screen.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as htmlParser;

class RegScreen extends StatefulWidget {
  const RegScreen({Key? key}) : super(key: key);

  @override
  _RegScreenState createState() => _RegScreenState();
}

class _RegScreenState extends State<RegScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  String? firstNameError;
  String? lastNameError;
  String? phoneNumberError;
  String? passwordError;
  String? confirmPasswordError;

Future<void> registerUser() async {
  var dio = Dio();
  var url = 'http://10.0.2.2:8000/registerAPI';

  try {
    var phoneNumber = '+216${phoneNumberController.text}';

    var response = await dio.post(
      url,
      data: {
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'phone_number': phoneNumber,
        'password1': passwordController.text,
        'password2': confirmPasswordController.text,
      },
      options: Options(
        contentType: Headers.jsonContentType,
        followRedirects: false,
        validateStatus: (status) => status != null && status <= 500,
      ),
    );

    print("Response Status Code: ${response.statusCode}");

    if (response.statusCode == 201) {
      // Successful registration
      print('User registered successfully');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      print('Failed to register user: ${response.statusCode}');
      var responseData = response.data;
      print('Validation errors:');
      print(responseData);

      // Handle validation errors based on response format
      if (responseData is Map<String, dynamic>) {
        // Handle JSON response
        setState(() {
          firstNameError = responseData['error']['first_name']?.first;
          lastNameError = responseData['error']['last_name']?.first;
          phoneNumberError = responseData['error']['phone_number']?.first;
          passwordError = responseData['error']['password1']?.first;
          confirmPasswordError = responseData['error']['password2']?.first;
        });
      } else {
        // Handle other response formats (e.g., HTML)
        // Implement parsing logic accordingly
      }
    }
  } on DioError catch (e) {
    // Dio error handling for network-related issues
    print('Dio error: ${e.message}');
    if (e.response != null) {
      print('Response status: ${e.response!.statusCode}');
      // Handle specific error scenarios if needed
    }
  } catch (e) {
    // Unexpected error handling
    print('Unexpected error: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        children: [
          Container(
            height: 200, // Adjust the height according to your design
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFC4DEF6),
                  Color.fromARGB(255, 102, 187, 236),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                'Create Your\nAccount',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: firstNameController,
                      onChanged: (value) {
                          setState(() {
                            firstNameError = null;
                          });
                        },  
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.check, color: Colors.grey),
                        label: Text(
                          'First Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        errorText: firstNameError,
                      ),
                      /*validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },*/
                    ),
                    TextFormField(
                      controller: lastNameController,
                      onChanged: (value) {
                           setState(() {
                             lastNameError = null;
                           });
                         },
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.check, color: Colors.grey),
                        label: Text(
                          'Last Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        errorText: lastNameError,
                      ),
                      /*validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },*/
                    ),
                    TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ], // Accepts only numeric input
                      controller: phoneNumberController,
                      onChanged: (value) {
                           setState(() {
                             phoneNumberError = null;
                           });
                         },
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.phone, color: Colors.grey),
                        label: Text(
                          'Phone Number',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        errorText: phoneNumberError,
                      ),
                      /*validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          if (value.length != 8) {
                            return 'Enter a valid 8-digit phone number';
                          }
                          return null;
                        },*/
                    ),
                    TextFormField(
                      obscureText: true,
                      controller: passwordController,
                      onChanged: (value) {
                           setState(() {
                             passwordError = null;
                           });
                         },
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.lock, color: Colors.grey),
                        label: Text(
                          'Password',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        errorText: passwordError,
                      ),
                      /*validator: (value) { _validatePassword(passwordController.text);
                        },*/
                    ),
                   TextFormField(
                      obscureText: true,
                      controller: confirmPasswordController,
                      onChanged: (value) {
                           setState(() {
                             confirmPasswordError = null;
                           });
                         },
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.lock, color: Colors.grey),
                        label: Text(
                          'Confirm Password',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        errorText: confirmPasswordError,
                      ),
                      
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        registerUser();
                      },
                      child: Container(
                        height: 55,
                        width: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFC4DEF6),
                              Color.fromARGB(255, 102, 187, 236),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'SIGN UP',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => loginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign in",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black,
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
    );
  }
}

