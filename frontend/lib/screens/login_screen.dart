import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/auth_service.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/reg_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<loginScreen> {
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    checkLoginStatus(); // Check login status on app startup
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString('sessionId');
    if (sessionId != null) {
      // Session exists, navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  Future<void> loginUser() async {
    if (phoneNumberController.text.isEmpty || passwordController.text.isEmpty) {
      // Show alert if any of the form fields are empty
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Incomplete Form'),
            content: Text('Please fill in all required fields.'),
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
      return;
    }

    setState(() {
    });

    var dio = Dio();
    var url = 'http://10.0.2.2:8000/loginAPI';

    try {
      var phoneNumber = '+216${phoneNumberController.text}';
      var response = await dio.post(
        url,
        data: {
          'phone_number': phoneNumber,
          'password': passwordController.text,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status != null && status <= 500,
        ),
      );

      if (response.statusCode == 200) {
        // Extract Cookie header
    AuthService.login();
    String cookieHeader = response.headers['set-cookie'].toString();
    print(cookieHeader);
    // Extract session ID and CSRF token
    String sessionId = _extractSessionId(cookieHeader);
    String csrfToken = _extractCsrfToken(cookieHeader);
  print("sessionid:  "); print(sessionId);
  print("csrftoken:  "); print(csrfToken);
    // Save session ID and CSRF token to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sessionId', sessionId);
    await prefs.setString('csrfToken', csrfToken);

    // Navigate to the home page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
      } else {
        // Display error message received from the server
        var responseData = response.data['error'];
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Login Failed'),
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
    } 
  }

 // Function to extract session ID from Cookie header
String _extractSessionId(String cookieHeader) {
 List<String> cookies = cookieHeader.split(RegExp(r'[;,]'));

  for (String cookie in cookies) {
    String trimmedCookie = cookie.trim();
    print("trimmed cookie part");
    print (trimmedCookie);
    if (trimmedCookie.startsWith('[sessionid=')) {
      return trimmedCookie.substring('[sessionid='.length);
    }
  }
  return '';
}

// Function to extract CSRF token from Cookie header
String _extractCsrfToken(String cookieHeader) {
List<String> cookies = cookieHeader.split(RegExp(r'[;,]'));
  for (String cookie in cookies) {
    String trimmedCookie = cookie.trim();
    if (trimmedCookie.startsWith('csrftoken=')) {
      return trimmedCookie.substring('csrftoken='.length);
    }
  }
  return '';
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFC4DEF6),
                  Color.fromARGB(255, 102, 187, 236),
                ],
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                'Hello\nSign in!',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              height: double.infinity,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      /*inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ], // Accepts only numeric input*/
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.phone, color: Colors.grey),
                        label: Text(
                          'Phone Number',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.lock, color: Colors.grey),
                        label: Text(
                          'Password',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to the homepage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Color.fromARGB(255, 32, 178, 166),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: () {
                        loginUser();
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
                          'SIGN IN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              // Navigate to the sign-up page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Sign up",
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
